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

#' Prepare data for Cadenza
#'
#' @param data Either a dataframe or a list of either with data to
#'     send back to Cadenza.
#' @param parameters Parameters to return to Cadenza. Defaults to an
#'     empty named list.
#' @param container_type String: The HTML content type for serializing
#'     data. Defaults to `"text/csv"`.  If data is a list, supply a
#'     vector with the content types for each element.
#' @param role A list of the same length as data with vectors of
#'     length `ncol(data[[el]])`.  Values `"dimension"` or
#'     `"measure"`, indicating the role for Cadenza.  Default values
#'     are `"measure"` for each column except IDs, Geometries or
#'     strings.
#' @param ... For future expansion: Further arguments passed on to
#'     generating the metadata for the Cadenza response-
#' @return List of class `cadenza_response` with elements `metadata`
#'     and other elements passed in as `data`argument.
#' @export
#'
#' @examples
#'
#' data <- data.frame(a = rnorm(10L), b = runif(10L), c = letters[1L:10L])
#'
#' # specify the container content type; this part will be serialized
#' # as JSON in the response.
#' as_cadenza_enrichment_calculation(data, container_type = "application/json")
#'
#' # List of data elements to return to Cadenza
#' data_list <- list(data, list(param = "a", vec = 1:13))
#' as_cadenza_enrichment_calculation(data_list,
#'   container_type = c("text/csv", "application/json"))

as_cadenza_enrichment_calculation <- function(data, parameters = empty_named_list, container_type = "text/csv", ...) { # nolint

  # Wrap data in a list if it is not already a list
  if (!inherits(data, "list")) {
    data <- list(data)
  }

  # name containers
  if (is.null(names(data))) {
    if (length(data) == 1L) {
      names(data) <- "data"
    } else {
      names(data) <- paste0(rep_len("data", length(data)), "_", seq_along(data))
    }
  }

  # container_type has to be the same length as data
  if (length(container_type) == 1L) {
    container_type <- rep_len(container_type, length.out = length(data))
  }

  metadata_containers <- purrr::pmap(
    .l = list(
      data = unname(data),
      container_name = names(data),
      container_type = container_type,
      ...
    ),
    .f = data_container_metadata
  )

  # setup body
  body <- c(
    list(
      metadata = list(
        parameters = parameters,
        dataContainers = metadata_containers
      )
    ),
    data
  )

  add_class(body, "cadenza_response")

} # END OF AS_CADENZA_ENRICHMENT_CALCULATION FUNCTION


#-------------------------------------------------------------------------------
# helper functions
#-------------------------------------------------------------------------------

# Cadenza data type
cadenza_datatype <- function(x) { # nolint false positive for cyclomatic complexity
  if (is.integer(x)) return("int64")
  if (is.double(x)) return("float64")
  if (is.character(x) || is.logical(x) || is.null(x)) return("string")
  if (inherits(x, "POSIXt")) return("zonedDateTime")
  if (is.sfc(x)) return("geometry")

  warning("Unknown type: ", class(x), "; Exporting as string")
  return("string")
} # END OF CADENZA_DATATYPE FUNCTION


# geometry type
geometry_type <- function(x) {
  if (is.sfc(x)) {
    class(x) |>
      stringi::stri_replace(replacement = "", regex = "^sfc_?") |>
      stringi::stri_trans_tolower() |>
      stringi::stri_join(collapse = "")
  } else {
    NA_character_
  }
} # END OF GEOMETRY_TYPE FUNCTION


# data container metadata
data_container_metadata <- function(data_container, container_name,
                                    container_type, print_names, role,
                                    ...) {
  stopifnot(is.character(container_name))
  stopifnot(is.character(container_type))
  # data container  has to be list-like
  stopifnot(is.list(data_container) && !is.null(names(data_container)))
  # if no print names are supplied use the names of the dataframe or
  # list inside data
  if (missing(print_names) || is.null(print_names)) {
    print_names <- names(data_container)
  } else {
    stopifnot(is.character(print_names))
  }

  data_type <- purrr::map_chr(data_container, cadenza_datatype)
  geom_type <- purrr::map_chr(data_container, geometry_type)

  # When the Column name is "ID", take that as the ID column given by Cadenza.
  random_group_name <- stringi::stri_rand_strings(n = 1L, length = 10L) # nolint

  attribute_groupname <- ifelse(names(data_container) == "ID",
                                "net.disy.cadenza.keyAttributeGroup",
                                random_group_name)

  # Define the role for each column If not specified, will default to
  # role "measure" except when an ID, geometry or string.
  if (missing(role) || is.null(role)) {
    role <- ifelse(names(data_container) == "ID"
                   | data_type %in% c("geometry", "string"),
                   "dimension",
                   "measure")
  }

  res <- list(
    type = jsonlite::unbox(container_type),
    name = jsonlite::unbox(container_name),
    columns = data.frame(
      name = names(data_container),
      printName = print_names,
      attributeGroupName = attribute_groupname,
      role = role,
      dataType = data_type,
      geometryType = geom_type,
      row.names = NULL
    )
  )

  # Drop column with geometry types if no there is no geometry present
  if (all(is.na(res$columns$geometryType))) res$columns$geometryType <- NULL

  return(res)
} # END OF DATA_CONTAINER_METADATA FUNCTION


# glue multipart
glue_multipart <- function(body, type, boundary) {

  stopifnot(inherits(body, "list"))
  stopifnot(rlang::is_named(body))
  stopifnot(is.character(boundary) && length(boundary) == 1L)
  stopifnot(length(type) == 1L || length(type) == length(body))

  glue::glue(
    "--<%boundary%>\nContent-Disposition: form-data; name=<%names(body)%>\nContent-Type: <%type%>\nContent-Transfer-Encoding: binary\n\n<%body%>\n", # nolint
    .open = "<%",
    .close = "%>",
    .trim = FALSE
  ) |>
    stringi::stri_join(collapse = "\n") |>
    paste0("--", boundary, "--\n", collapse = "")
} # END OF GLUE_MULTIPART FUNCTION


#-------------------------------------------------------------------------------
# custom serializer
#-------------------------------------------------------------------------------

#' Custom serializers
#'
#' @param serialize_fn Function with which the individual parts will
#'     be serialized.  The function has to return a vector or list of
#'     strings and has to have the attribute `type` with the HTML
#'     content type of each part.
#' @param boundary The boundary string with which the parts are to be
#'     separated.  If `NULL` a random string of 30 characters will be
#'     generated and used.
#' @param ... Additional arguments to be passed to the serialize
#'     function.
#'
#' @describeIn serializers Serialize as multipart-form
#' @export
#'
#' @examples
#' pr() |>
#'   pr_get(
#'     "/form",
#'     handler = function() list(data.frame(x = rnorm(10), y = runif(10)),
#'                               list(param = "b", value = 12)),
#'     serializer = serializer_multi(
#'       serialiize_fn = function(val) lapply(val, )))
serializer_multi <- function(serialize_fn, boundary = NULL, ...) {
  if (is.null(boundary)) {
    boundary <- stringi::stri_rand_strings(n = 1L, length = 30L)
  }

  type <- paste0("multipart/form-data; boundary=", boundary, "; charset=UTF-8")

  multipart_maker <- function(val) {
    serialized <- serialize_fn(val, ...)
    stopifnot(inherits(serialized, "multipart"))
    character_body <- glue_multipart(serialized,
                                     type = attr(serialized, "type"),
                                     boundary) |>
      # Format the body with \r\n as required by MIME multipart encoding
      stringi::stri_replace_all(replacement = "\r\n", regex = "\n")

    charToRaw(character_body)
  }
  plumber::serializer_content_type(type, multipart_maker)
}


#' @describeIn serializers Serialize the multipart-form required by Cadenza for
#'                         enrichments and calculations
#'
#' @importFrom dplyr mutate across where everything
#' @export
serializer_cadenza_enrichment_calculation <- function(...) { # nolint
  serialize_cadenza_body <- function(val, ...) {

    # Check if the response value has the correct format
    if (!inherits(val, "cadenza_response")) {
      stop(paste("Use as_cadenza_enrichment_calculation(result, ...)",
                 "on the last line of your endpoint function."))
    }

    metadata_containers <- val$metadata$dataContainers

    switch_serializer <- function(x, type) {

      switch(
        type,
        "application/json" = jsonlite::toJSON(x, pretty = TRUE),
        "text/csv" =
          x |>
          mutate(
            across(everything(), as.character)
          ) |>
          vroom::vroom_format(delim = ";", quote = "all", escape = "double") |>
          stringi::stri_replace_all(replacement = "\r\n", regex = "\n")
      )
    }

    content_types <- c(
      # Metadata is always JSON
      metadata = "application/json",
      # Make sure the correct content type is assigned to each container
      purrr::set_names(purrr::map_chr(metadata_containers, "type"),
                       purrr::map_chr(metadata_containers, "name"))
    )

    serialized_body <- purrr::imap(val, \(el, idx) switch_serializer(el, content_types[[idx]])) # nolint

    attr(serialized_body, which = "type") <- content_types
    add_class(serialized_body, "multipart")
  }

  serializer_multi(serialize_fn = serialize_cadenza_body, ...)
}


# register the defined serializers
register_serializer_enrichment_calculation_onLoad <- function() { # nolint
  plumber::register_serializer("multi", serializer_multi)
  plumber::register_serializer("cadenza_enrichment_calculation",
                               serializer_cadenza_enrichment_calculation)
}
