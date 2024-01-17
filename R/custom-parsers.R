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

#' Find the boundary in the content type multipart MIME header
#'
#' @param content_type the content of the content_type mime header.
detect_boundary <- function(content_type) {
  if (!stringi::stri_detect_fixed(content_type, "boundary=",
                                  case_insensitive = TRUE))
    stop("No boundary found in multipart content-type header: ", content_type)
  stringi::stri_match_first_regex(content_type, "boundary=([^; ]{2,})",
                                  case_insensitive = TRUE)[, 2]
}



#' Custom parsers
#'
#' A parser is responsible for returning a valid R object based on the
#' document-type.  The Cadenza parser takes a multipart form with a
#' specific structure and returns a dataframe.
#'
#' See [plumber::parser_form()] for details and
#' [plumber::registered_parsers()] for a list of registered parsers names.
#'
#' @describeIn parsers Parse multipart-form request from Cadenza
#' @return
#'  A list with the following elements:
#'  - data: the data sent by Cadenza; Can be a dataframe or a list
#'  - column_info: a dataframe with metadata regarding the columns in data
#'    if it is a dataframe
#'  - metadata: a list with all metadata supplied by Cadenza
#'  - ... Further elements linked to parameters specified
#'    in the extension description
#' @export
parser_cadenza <- function() {
  function(value, content_type, ...) {
    # extract the raw MIME content from a multipart upload.
    # This is a specialized parser handling only the Cadenza POST request.
    boundary <- detect_boundary(content_type)
    raw_multipart <- webutils::parse_multipart(value, boundary)
    # list with 2:n elements: metadata and multiple data containers.
    # They are described in the OpenAPI specification for the Cadenza
    # Advanced Analytics Service Programming Interface

    # metadata still works
    parsed_metadata <- jsonlite::parse_json(
      rawToChar(raw_multipart$metadata$value), # nolint indenting to align would break line length
      simplifyVector = FALSE)
    # getting no data
    if (length(raw_multipart$data) != 0) {
      parsed_data <- vroom::vroom(I(raw_multipart$data$value), delim = ";", show_col_types = TRUE) # nolint
    } else {
      parsed_data <- list()
    }
    parameters <- parsed_metadata$parameters
    if (length(parsed_metadata$dataContainers) > 0) {
      column_info <- purrr::map(parsed_metadata$dataContainers[[1L]]$columns, tibble::as_tibble) |> # nolint
        purrr::list_rbind()
    } else {
      column_info <- list()
    }

    message("Number of data containers: ",
            length(parsed_metadata$dataContainers))

    # Sort by ID if given
    if ("ID" %in% colnames(parsed_data)) {
      parsed_data <- parsed_data[order(parsed_data$ID), ]
    }

    c(list(data = parsed_data, column_info = column_info,
           metadata = parsed_metadata), parameters)
  }
}

#' @describeIn parsers Parse any delimited files. See [vroom::vroom()]
#'     for details.
#' @param ... Additional arguments passed on to [vroom::vroom()].
#' @export
parser_delim <- function(...) {
  vroom_helper <- function(raw, delim = NULL, ...) {
    suppressMessages(vroom::vroom(raw, delim, show_col_types = FALSE))
  }

  plumber::parser_text(function(value) {
    vroom_helper(value, ...)
  })
}

register_parsers_onLoad <- function() { # nolint accept onLoad
  plumber::register_parser("delim", parser_delim,
                           fixed = c("application/csv",
                                     "application/x-csv",
                                     "text/csv",
                                     "text/x-csv"))
  plumber::register_parser("cadenza", parser_cadenza,
                           fixed = "multipart/form-data",
                           regex = "^multipart/")
}
