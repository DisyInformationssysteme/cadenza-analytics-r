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

library("plumber", quietly = TRUE)

#' Build the Capabilities GET-response.
#'
#' @param extension A list of a parameters of the analytics extension.
#' It requires a printName, extensionType, and attributeGroups.
#' It can optionally take parameters.
#' @return a GetCapabilities response.
#' @export
#'
#' @examples
#' function() {
#'   extension(
#'     printName = "Data Generation",
#'     extensionType = "calculation",
#'     attributeGroups = list(
#'       attribute_group(
#'         name = "datgen",
#'         printName = "Data Generation",
#'         dataTypes = c("int64", "float64"),
#'         maxAttributes=1L
#'       )
#'     ),
#'     parameters = list(
#'       parameter(
#'         name = "cols",
#'         printName = "Please select the number of columns to generate.",
#'         parameterType = "select",
#'         options = c(2, 3, 4, 5, 6, 7, 8, 9, 10),
#'         required = TRUE,
#'         defaultValue = c("2")
#'       )
#'     )
#'   )
#' }
serializer_cadenza_capabilities <- function(...) { # nolint symbol length
  # this is currently purely an alias to enable adapting the API
  # without change to analytics extensions.
  serializer_unboxed_json(...)
}

#' The extension description
#' @export
extension <- function(...) {
  list(...)
}

#' A group of attributes used in the extension
#' @export
attribute_group <- function(...) {
  list(...)
}

#' A parameter that can or must be passed to the extension
#' @export
parameter <- function(...) {
  list(...)
}

# register the defined serializer
register_serializer_capabilities_onLoad <- function() { # nolint symbol length + onLoad
  plumber::register_serializer("cadenza_capabilities_response",
                               serializer_cadenza_capabilities)
}
