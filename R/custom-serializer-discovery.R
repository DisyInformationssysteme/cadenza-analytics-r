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

#' Build the Discovery GET-response.
#'
#' @param ... a [discovery()] structure.
#'
#' @return a discovery response.
#' @export
#'
#' @examplesIf interactive()
#' function() {
#'   discovery(
#'     extensions = list(
#'       extension_reference(
#'         extensionPrintName = "The Name",
#'         extensionType = "calculation",
#'         relativePath = "/path-of-extension"
#'       )
#'     )
#'   )
#' }
serializer_cadenza_discovery <- function(...) { # nolint symbol length
  # this is currently purely an alias to enable adapting the API
  # without change to analytics extensions.
  serializer_unboxed_json(...)
}

#' The description of one extension
#'
#' @param ... requires a printName, extensionType, and attributeGroups.
#' It can optionally take additional parameters.
#' For examples, see [serializer_cadenza_discovery()]
#'
#' @export
extension_reference <- function(...) {
  list(...)
}


#' The description for available extensions
#'
#' @param extensions a list of [extension_reference()]'s. For examples, see [serializer_cadenza_discovery()]
#'
#' @export
discovery <- function(...) {
  list(...)
}


# register the defined serializer
register_serializer_discovery_onLoad <- function() { # nolint symbol length + onLoad
  plumber::register_serializer("cadenza_discovery_response",
                               serializer_cadenza_discovery)
}
