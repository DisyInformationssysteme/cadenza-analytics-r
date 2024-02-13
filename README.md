# Cadenza Analytics R

Cadenza Analytics R is a convenience-library which enables
[disy Cadenza](https://www.disy.net/de/produkte/cadenza/datenanalyse-software/)
to use R-scripts as analytics extensions.

This package is in Beta-Status: it can be used for testing, but there
may be breaking changes before a full release.

## Dependencies

Core dependencies:

- R: https://www.r-project.org/
- Compilers for C, C++, and Fortran to build libraries. For example GCC: https://gcc.gnu.org/
- make, for example GNU make: https://www.gnu.org/software/make/

System dependencies of used r-packages:

- libxml2: http://xmlsoft.org/
- agg 2.4: https://sourceforge.net/p/agg/svn/HEAD/tree/agg-2.4/
- libgit2: https://libgit2.org/
- libsodium: https://libsodium.org
- freetype: https://freetype.org/

Build time dependencies:

- tar: https://www.gnu.org/software/tar/
- pkg-config: https://www.freedesktop.org/wiki/Software/pkg-config
- diffutils: https://www.gnu.org/software/diffutils/
- gzip: https://www.gnu.org/software/gzip/
- xz: https://tukaani.org/xz/

RStudio provides the most common development environment for R:
https://posit.co/download/rstudio-desktop/




## Installation and Setup

You can install this package by running

```
devtools::install_github("https://github.com/DisyInformationssysteme/cadenza-analytics-r")
```

Once installed, include the package as you normally would:

```r
library(CadenzaAnalytics)
```

To generate demo code that you can tweak and build your own extension on, simply run:

```r
CadenzaAnalytics::create_analytics_extension()
```

`CadenzaAnalytics` uses [swagger](https://swagger.io) and [plumber](https://www.rplumber.io) in tandem to enable users to host their own analytics extensions. Hosting endpoints generally looks like this:

````r
root <- Plumber$new()
a <- Plumber$new('path_to_script_1')
b <- Plumber$new('path_to_script_2')
pr_mount(root, '/the-route', a)
pr_mount(root, '/the-route', b)
options("plumber.port" = 9292)
root$run()
````

To generate a Dockerfile that can help you deploy your extension using Docker, run

```r
CadenzaAnalytics::create_dockerfile()
```



# Defining an Analytics Extension

## Defining an API

For disy Cadenza to make use of the APIs, both a `@get` and `@post` request must be defined.  This can be done using the plumber package similar to the following:

```r
#* 'GET description'
#* 'GET parameter description'
#* @get '/endpoint-name'
#* @serializer 'GET serializer'
function(){

}

#* 'POST description'
#* @preempt 'POST Filter'
#* @parser 'POST parser'
#* @param 'Post parameter'
#* @post '/endpoint-name'
#* @serializer 'POST serializer'
function(){

}
```

When developing an analytics extension, please refer to the Cadenza Advanced Analytics Service Programming Interface (SPI).

A working minimal example would be the following:

```r
library(dplyr)

#* GETCapabilities-Request of the row wise sum extension
#* This extension's parameters are:
#* @get /rowSum
#* @serializer cadenza_capabilities_response
function() {
  extension(
    printName = "Calculate row wise sum",
    extensionType = "enrichment",
    attributeGroups = list(
      attribute_group(
        name = "toSum",
        printName = "Columns to use",
        dataTypes = c("int64", "float64"),
        minAttributes = 1L
      )
    )
  )
}

## POST --------------
#* Compute row wise sums
#* @post /rowSum
#* @parser cadenza
#* @serializer cadenza_enrichment_calculation
function(data, metadata, column_info) {

  # Select the colums to sum over
  to_sum <- column_info |>
    filter(attributeGroupName == "toSum") |>
    pull(name)
  # Select the ID column
  id_column <- column_info |>
    filter(attributeGroupName != "toSum") |>
    pull(name)

  # Sum across each row
  colnames(data)[min(which(regexpr(id_column, colnames(data)) > -1))] <- "ID"
  result <- data |>
    rowwise("ID") |>
    summarise(result = sum(c_across(c(!!!to_sum)))) |>
    ungroup()

  as_cadenza_enrichment_calculation(result)
}
```

## Adding extension discovery

Implement a discovery endpoint following `inst/plumber/discovery.R`.

```r
# GET ----------------
#* DiscoveryRequest for the defined analytics extensions
#* @get /
#* @serializer cadenza_discovery_response
function () {
  discovery(
    list(
      extension_reference(
        extensionPrintName = "The Name",
        extensionType = "calculation",
        relativePath = "/path-of-extension"
      )
    )
  )
}
```

# Using the Analytics extension

Add the URL `https://host:port/the-route/endpoint-name` as analytics extension.

- `/the-route` is the route chosen in mounting the script file on root.
- `/endpoint-name` is the endpoint defined in GetCapabilities.

