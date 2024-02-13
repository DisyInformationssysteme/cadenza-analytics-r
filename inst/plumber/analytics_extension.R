library(CadenzaAnalytics)
library(plumber)

# Generate a new router as root
root <- Plumber$new("discovery.R")

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

# Set the API's port and launch it
options("plumber.port" = 9292)
root$run()
