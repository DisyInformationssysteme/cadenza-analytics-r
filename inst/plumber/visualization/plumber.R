library("dplyr", quietly = TRUE)
# GET ----------------
#* GetCapabilities-Request of the Static Image plot analytics extension.
#* @get /staticImage
#* @serializer cadenza_capabilities_response
function() {
  extension(
    printName = "Static Image",
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
#* Create a Static Image, ignoring the given Data
#* @post /staticImage
#* @parser cadenza
#* @serializer cadenza_visualization
function(data, metadata, column_info, res) {

  # rename the cryptic column name
  data <- dplyr::rename(data, Data = column_info$name)

  # extract parameters as numeric type
  width <- ifelse(metadata$parameters[[1]]$name == "net.disy.cadenza.imageWidth",
                  as.numeric(metadata$parameters[[1]]$value),
                  NA)
  height <- ifelse(metadata$parameters[[2]]$name == "net.disy.cadenza.imageHeight",
                  as.numeric(metadata$parameters[[2]]$value),
                  NA)
  ratio <- ifelse(metadata$parameters[[3]]$name == "net.disy.cadenza.devicePixelRatio",
                  as.numeric(metadata$parameters[[3]]$value),
                  NA)
  # the filename
  plotfile <- file.path(tempdir(),
                        paste0(as.character(runif(1) * 1e16), ".png", sep = ""))
  binData <- readBin("visualization/cadenza-anex-r-dataflow.png", "raw", 1e10)
  writeBin(binData, plotfile)

  # response
  res <- as_cadenza_visualization(res, plotfile)
  return(res)

}
