<pre>    
 <b>!! This module is currently in beta status !!</b>

    It can be used for testing, but there may be breaking changes before a full release.
    This documentation is still under developement as well.

</pre>


# disy Cadenza Analytics Extensions

An Analytics Extension extends the functional spectrum of [disy Cadenza](https://www.disy.net/en/products/disy-cadenza/) with an analysis function or a visualisation type. An Analytics Extension is a web service that exchanges structured data with disy Cadenza via the Cadenza API. A user can integrate an analysis extension into disy Cadenza via the Management Center and manage it there (if they have the appropriate rights).

As of disy Cadenza Autumn 2023 (9.3), the following types and capabilities of analysis extensions are officially supported:

- **Visualization**
  The Analytics Extension type `visualization` provides a new visualization type for displaying a bitmap image (PNG).

- **Data enrichment**
  The Analytcs Extension type `enrichment` returns data that enriches an existing Cadenza object type by adding additional attributes, which virtually add additional columns to the original data set.

- **Data generation**
  The Analytics Extension type `calculation` provides a result data set that is created as a new Cadenza object type.

## Communication

An Analytics Extension defines one endpoint that, depending on the HTTP method of the request, is used to supply the Extension's configuration to disy Cadenza, or exchange data and results with Cadenza respectively.

When receiving an `HTTP(S) GET` request, the endpoint returns a JSON representation of the extention's configuration. This step is executed once when registering the Analytics Extension from the disy Cadenza Management Center GUI and does not need to be repeated unless the extension's configuration changes.

By sending an `HTTP(S) POST` request to the same endpoint and including the data, metadata and parameters as specified in the extension's configuration as payload, the extension is executed. This step is executed each time that the Analytics Extension is invoked from the disy Cadenza GUI and Cadenza takes care of properly formatting the payload.

The `cadenzaanalytics` module provides the functionality to abstract the required communication and easily configure the Analytics Extension's responses to the above requests. 


# Installation

As long as this package is in beta, it is only available on GitHub, and an installation via source is necessary.

Furthermore, a corresponding version will be packaged as source code with each release of disy Cadenza.

## Requirements and Dependencies

The requirements of the extension are documented in the [README](https://github.com/DisyInformationssysteme/cadenza-analytics-r/blob/main/README.md). 

The first version of disy Cadenza that supports Analytics Extensions is disy Cadenza Autumn 2023 (9.3). For each disy Cadenza version, the correct corresponding library version needs to be used:

|disy Cadenza version |  cadenzaanalytics version |
|---------------------|---------------------------|
| 9.3 (Autumn 2023)   |             < 0.2.0 (beta)|


