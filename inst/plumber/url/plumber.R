library("dplyr", quietly = TRUE)
# GET ----------------
#* GetCapabilities-Request of the Url analytics extension.
#* @get /website
#* @serializer cadenza_capabilities_response
function() {
  extension(
    printName = "Show the Disy website",
    extensionType = "visual",
    attributeGroups = list()
  )
}

## POST --------------
#* Create a Text describing the data column.
#* @post /website
#* @parser cadenza
#* @serializer cadenza_text
function(data, metadata, column_info, res) {

  # rename the cryptic column name
  url <- "https://www.disy.net"

  # response
  as_cadenza_url(res, url)

}
