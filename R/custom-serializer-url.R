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

# static boundary of random characters per run.
boundary <- stringi::stri_rand_strings(n = 1L, length = 30L)

#' Prepare text results for Cadenza
#'
#' @param res The Plumber response construct
#' @param text The text created in the Plumber R file
#'
#' @return The Plumber response construct with the text added
#' @export
#'
#' @examples
#' res <- list("injected from plumber")
#' res <- as_cadenza_url(res, "https://example.com")
#' res$status
#' res$headers
#' length(res$body)

as_cadenza_url <- function(res, text) {
  # preparations (NOTE: the body will be concatenated in RAW format to avoid
  # problems with 0x00 in the plot file when converting to CHAR)
  file_size <- nchar(charToRaw(text))

  boundary_raw <- charToRaw(boundary)

  crlf <- "\r\n"
  crlf_raw <- charToRaw(crlf)

  boundary_delimiter_raw <- charToRaw("--")

  # meta data header
  meta_data_header_array <- c(
    "Content-Disposition: form-data; name=\"metadata\"",
    "Content-Type: application/json",
    "Content-Transfer-Encoding: binary"
  )

  meta_data_header_raw <- charToRaw(stringi::stri_join(meta_data_header_array,
                                                       collapse = crlf))

  # meta data response
  meta_data_response <- '
  {
    \"dataContainers\": [
      {
        \"type\": \"text/uri-list\",
        \"name\": \"data\",
        \"columns\": [
        ]
      }
    ]
  }
  '

  meta_data_response_raw <- charToRaw(meta_data_response)

  # data header
  data_header_array <- c(
    glue::glue("Content-Disposition: form-data; name=\"data\"; filename=\"urls.txt\""), # nolint line length
    "Content-Type: text/uri-list",
    glue::glue("Content-Length: {file_size}"),
    "Content-Transfer-Encoding: binary"
  )

  data_header_raw <- charToRaw(stringi::stri_join(data_header_array,
                                                  collapse = crlf))

  # data reponse
  data_response_raw <- charToRaw(text)

  # put it all together
  body <- c(boundary_delimiter_raw, boundary_raw, crlf_raw,
    meta_data_header_raw, crlf_raw, crlf_raw,
    meta_data_response_raw, crlf_raw, crlf_raw,
    boundary_delimiter_raw, boundary_raw, crlf_raw,
    data_header_raw, crlf_raw, crlf_raw,
    data_response_raw, crlf_raw, crlf_raw,
    boundary_delimiter_raw, boundary_raw, boundary_delimiter_raw,
    crlf_raw
  )

  # response headers
  response_headers <- list(
    "Content-Encoding" = "multipart/form-data",
    "Content-Type" = glue::glue("multipart/form-data; boundary={boundary}; charset=UTF-8") # nolint line length
  )

  # combined response
  res$status <- 200
  res$headers <- response_headers
  res$body <- body

  return(res)
}



#' @describeIn serializers Serialize the multipart-form required by
#'     Cadenza for text
#'
#' @importFrom plumber serializer_octet
#' @export

serializer_cadenza_url <- function(...) { # nolint symbol length
  plumber::serializer_octet(...)
}



# register the defined serializer
register_serializer_url_onLoad <- function() { # nolint symbol length + onLoad
  plumber::register_serializer("cadenza_url",
                               serializer_cadenza_url)
}
