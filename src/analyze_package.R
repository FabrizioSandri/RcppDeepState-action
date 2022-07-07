require(RcppDeepState)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")
location <- Sys.getenv("INPUT_LOCATION")

deepstate_harness_compile_run(file.path(GitHub_workspace, location))
result <- deepstate_harness_analyze_pkg(file.path(GitHub_workspace, location))


# Auxiliary function used to get the number of errors for a single file that has
# been analyzed. Each "logtableElement" correspond to a "data.table" instance 
# where the second dimension describes the number of columns, whereas the second 
# describes the number of errors found.
getErrors <- function(logtableElement){
    return (dim(vec)[1])
}

errors <- sapply(result$logtable,  getErrors)

# print all the errors and return a proper exit status code
if (any(errors > 0)){
    print(result)
    print(result$logtable)

    quit(status=1)  # error code
}else{
    quit(status=0)  # success
}

