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

is.sfc <- function(x) { # nolint prefer consistency
  inherits(x, "sfc")
}

add_class <- function(x, class) {
  class(x) <- c(class, class(x))
  x
}

generate_boundary <- function() {
  stringi::stri_rand_strings(n = 1L, length = 30L)
}

#' Empty Named List
#'
#' When building a JSON from an R list of lists, if you want to have
#' an empty object instead of an empty array, you can use this object.
#'
#' @examples
#' # a is parsed as an empty object, while b is parsed as an empty array
#' jsonlite::toJSON(list(a = empty_named_list, b = list()))
#' # returns {"a":{},"b":[]}
#' @export
empty_named_list <- setNames(list(), character(0))
