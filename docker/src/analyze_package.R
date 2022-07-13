require(RcppDeepState)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")
location <- Sys.getenv("INPUT_LOCATION")
seed <- Sys.getenv("INPUT_SEED")
time_limit <- Sys.getenv("INPUT_TIME_LIMIT")
max_inputs <- Sys.getenv("INPUT_MAX_INPUTS")
fail_ci_if_error <- Sys.getenv("INPUT_FAIL_CI_IF_ERROR")

deepstate_harness_compile_run(file.path(GitHub_workspace, location), seed=seed,
    time.limit.seconds=time_limit)

result <- deepstate_harness_analyze_pkg(file.path(GitHub_workspace, location),
    max_inputs=max_inputs)


# Auxiliary function used to get the number of errors for a single file that has
# been analyzed. Each "logtableElement" correspond to a "data.table" instance 
# where the second dimension describes the number of columns, whereas the second 
# describes the number of errors found.
getErrors <- function(logtableElement){
    return (dim(logtableElement)[1])
}

errors <- sapply(result$logtable,  getErrors)
status <- 0

# print all the errors and return a proper exit status code
if (any(errors > 0)){
    print(result)
    print(result$logtable)

    if (fail_ci_if_error == "true"){
        status <- 1
    }
}

quit(status=status)  # return an error code