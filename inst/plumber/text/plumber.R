library("dplyr", quietly = TRUE)
# GET ----------------
#* GetCapabilities-Request of the Text analytics extension.
#* @get /describe
#* @serializer cadenza_capabilities_response
function() {
  extension(
    printName = "Describe the data",
    extensionType = "visual",
    attributeGroups = list(
      attribute_group(
        name = "data",
        printName = "Data column (ignored)",
        dataTypes = c("int64", "float64"),
        minAttributes = 1L,
        maxAttributes = 1L
      )
    )
  )
}

## POST --------------
#* Create a Text describing the data column.
#* @post /describe
#* @parser cadenza
#* @serializer cadenza_text
function(data, metadata, column_info, res) {

  # show the cryptic column name
  text <- column_info$name

  # response
  as_cadenza_text(res, text)

}
