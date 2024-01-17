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

# install Cadenza Analytics using devtools

# remove the Cadenza Analytics package in case it's already in the current session
if (require("CadenzaAnalytics", character.only = TRUE)) {
  remove.packages("CadenzaAnalytics")
}
# install and load devtool library
packages <- c("devtools")

# install packages
for (P in packages) {
  if (!require(P, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkgs = P, dependencies = TRUE)
  }
}

# load devtool library
library(devtools)

# installation
devtools::install(".", upgrade = "ask")

# now load the plumber stuff (should not be done at the beginning)
library(CadenzaAnalytics)
library(plumber)

# Generate a new router as root
root <- Plumber$new("inst/plumber/discovery.R")

# For each hello world extension generate a new router

# Locate all the files that are to be mounted onto the router
l <- as.list(list.files(pattern="plumber.R", recursive=TRUE))
p <- list()
for (i in 1:length(l)){
 p[[i]] <- Plumber$new(paste0(getwd(), "/", l[i]), envir =)
}
# Mount the extension routers onto the root router
for (i in 1:length(p)){
  # mount extensions by path.
  # example: mount inst/plumber/calculation/plumber.R on /calculation
  # plumber.R defines the sub-path.
  # In this case it is  /hello, so the endpoint is /calculation/hello
  pr_mount(root, paste0("/",gsub("/plumber.R","", gsub("inst/plumber/","", l[i]))), p[[i]])
}

# load demo analytics extensions if they exist
wd <- getwd()
demo_wd <- gsub("cadenza-analytics-r", "demo-analytics-extensions", wd)
if (file.exists(demo_wd)) {
  setwd(demo_wd)
  if (file.exists("load_extensions.R")) {
    source("load_extensions.R")
  }
  setwd(wd)
}

# Set the API's port and launch it
options("plumber.port" = 9292)
root$run()
