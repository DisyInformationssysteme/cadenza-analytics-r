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
