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

#' Generate Demo Extensions
#' @export
create_analytics_extension <- function() {
  demo_extension_path <- fs::path_package("inst", "plumber", package="CadenzaAnalytics")
  files <- list.files(demo_extension_path, recursive = TRUE, full.names = TRUE)
  working_path = getwd()
  created_files <- sapply(files, function(x) {
    # Replace the source_dir path with dest_dir in each file's path
    new_path <- gsub(demo_extension_path, working_path, x)
    # Extract the directory path of the new file location
    new_dir <- dirname(new_path)

    # Check if the directory exists, if not, create it
    if(!dir.exists(new_dir)) {
      dir.create(new_dir, recursive = TRUE)
    }

    # Finally, copy the file
    file.copy(x, new_path)
  })
}

#' Generate Basic Dockerfile
#' @export
create_extension_dockerfile <- function() {
  dockerfile_path <- fs::path_package("inst", "docker", package="CadenzaAnalytics")
  files <- list.files(dockerfile_path, recursive = TRUE, full.names = TRUE)
  working_path = getwd()
  created_files <- sapply(files, function(x) file.copy(x, gsub(dockerfile_path, working_path, x)))
}
