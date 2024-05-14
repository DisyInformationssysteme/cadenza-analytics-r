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




## Installation and Setup

You can install this package by running

```
devtools::install_github("https://github.com/DisyInformationssysteme/cadenza-analytics-r")
```

Once installed, include the package as you normally would:

## Create and deploy Analytics Extensions

To generate demo code that you can tweak and build your own extension on, simply run:

```r
CadenzaAnalytics::create_analytics_extension()
```

`CadenzaAnalytics` uses [swagger](https://swagger.io) and [plumber](https://www.rplumber.io) in tandem to enable users to host their own analytics extensions.

## Update the API documentation

In an R-session run roxygen2 and pkgdown:


````r
roxygen2::roxygenize()
pkgdown::build_site()
````

To generate a Dockerfile that can help you deploy your extension using Docker, run

```r
CadenzaAnalytics::create_dockerfile()
```



# Defining an Analytics Extension

Details and examples about defining analytics extension for disy
Cadenza with R are described in `vignette("CadenzaAnalytics")`.

# Using the Analytics extension

Add the URL `https://host:port/the-route/endpoint-name` as analytics extension.

- `host:port` are by default 127.0.0.1:9292
- `/the-route` is the route chosen in mounting the script file on root
- `/endpoint-name` is the endpoint defined in GetCapabilities

