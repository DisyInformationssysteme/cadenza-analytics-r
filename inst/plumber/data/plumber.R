# Copyright 2024 Disy Informationssysteme GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#* @apiTitle Generate Hello World


#* GetCapabilities-Request of the generate random data extension.
#* This extension's parameters are:
#* @get /hello
#* @serializer cadenza_capabilities_response
function() {
  extension(
    printName = "Hello Calculation",
    extensionType = "data",
    attributeGroups = list(
      attribute_group(
        name = "hello",
        printName = "Hello World",
        dataTypes = c("int64", "float64"),
        maxAttributes=1L
      )
    ),
    parameters = list(
      parameter(
        name = "cols",
        printName = "Please select the number of columns to generate.",
        parameterType = "select",
        # possible parameter types: string, int64, float64, zonedDateTime, geometry, select, boolean
        options = c(1, 2), # allowed values for the select
        required = TRUE,
        defaultValue = c("1")
      ),
      parameter(
        name = "geo",
        printName = "Please choose a geometry.",
        parameterType = "geometry",
        required = TRUE,
        requestedSrs = "EPSG:3857" # pseudo mercator, for geometry
      )
    )
  )
}

## POST --------------
#* Execute the data generation.
#* @parser cadenza
#* @param metadata
#* @post /hello
#* @serializer cadenza_enrichment_calculation
function(metadata) {
    cols <- ifelse(metadata$parameters[[1]]$name == "cols",
                   metadata$parameters[[1]]$value,
                   "1") # default: 1
    srs <- ifelse(metadata$parameters[[2]]$name == "geo",
                  metadata$parameters[[2]]$srs,
                  metadata$parameters[[2]]$name) # default: 1
    inputColumnName <- metadata$dataContainers[[1]]$columns[[1]]$name

    result <- ifelse(cols == "1",
                     list(data.frame(a = 83110)),
                     list(data.frame(a = 83110, b = 30270)))

  as_cadenza_enrichment_calculation(result, measureAggregation = "average", format = "#,##0.00")
}
