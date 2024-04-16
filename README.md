# Cadenza Analytics R

**CadenzaAnalytics** is the official package for fast and easy creation of [disy Cadenza](https://www.disy.net/en/products/disy-cadenza/) analytics extensions with R. It enables extending disy Cadenza with advanced analytics using R.

This package is in **beta status**: it can be used for testing, but there
may be breaking changes before a full release.

Find the docs at https://disyinformationssysteme.github.io/cadenza-analytics-r

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

## Example

Example extensions can be found in  [inst/plumber](inst/plumber).

To test the example extension, follow the installation and setup instructions.

A development server will be started on localhost `http://127.0.0.1:9292`. The analytics extension can now be registered and used in disy Cadenza.

It is not recommended to use the development server in a production environment.


## Installation and setup in plain R

After cloning the git repository, install the dependencies and the
package by sourcing `install_CadenzaAnalytics.R` **in an R session**
inside the cloned directory (`cadenza-analytics-r`):

```r
source("install_CadenzaAnalytics.R")
```

The file `install_CadenzaAnalytics.R` contains some
user-settings. Adjust those to your needs.

## Installation and setup in R-Studio

After cloning the git repository, use

```r
library(CadenzaAnalytics)
```

to import the package into R. Note, that `CadenzaAnalytics.Rproj` needs to
be in the same directory as your R-script for this to work.

Cadenza Analytics R uses swagger and plumber in tandem to enable users
to host their own analytics extensions. To start, either use
`install_CadenzaAnalytics.R` or host your own endpoints:

````r
root <- Plumber$new()
a <- Plumber$new('path_to_script_1')
b <- Plumber$new('path_to_script_2')
pr_mount(root, '/the-route', a)
pr_mount(root, '/the-route', b)
options("plumber.port" = 9292)
root$run()
````

## Update the API documentation

In an R-session run roxygen2 and pkgdown:

````r
roxygen2::roxygenize()
pkgdown::build_site()
````

# Defining an Analytics Extension

Details and examples about defining analytics extension for disy
Cadenza with R are described in `vignette("CadenzaAnalytics")`.

# Using the Analytics extension

Add the URL `https://host:port/the-route/endpoint-name` as analytics extension.

- `host:port` are by default 127.0.0.1:9292
- `/the-route` is the route chosen in mounting the script file on root
- `/endpoint-name` is the endpoint defined in GetCapabilities

