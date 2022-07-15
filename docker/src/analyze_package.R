require(RcppDeepState)
require(data.table)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")
location <- Sys.getenv("INPUT_LOCATION")
seed <- Sys.getenv("INPUT_SEED")
time_limit <- Sys.getenv("INPUT_TIME_LIMIT")
max_inputs <- Sys.getenv("INPUT_MAX_INPUTS")
fail_ci_if_error <- Sys.getenv("INPUT_FAIL_CI_IF_ERROR")
GitHub_server_url <- Sys.getenv("GITHUB_SERVER_URL")
GitHub_repository <- Sys.getenv("GITHUB_REPOSITORY")
GitHub_head_ref <- Sys.getenv("GITHUB_HEAD_REF")

deepstate_harness_compile_run(file.path(GitHub_workspace, location), seed=seed,
    time.limit.seconds=time_limit)

result <- deepstate_harness_analyze_pkg(file.path(GitHub_workspace, location),
    max_inputs=max_inputs)


# Auxiliary function used to get the errors positions for a single file that has
# been analyzed. Each "logtableElement" correspond to a "data.table" instance 
# where the second dimension describes the number of columns, whereas the second 
# describes the number of errors found.
getErrors <- function(logtableElement){
    return (dim(logtableElement)[1]>0)
}

getFunctionName <- function(test_path){
    analyzed_fun <- unlist(strsplit(test_path, "/"))
    analyzed_fun <- analyzed_fun[length(analyzed_fun)-2]
    return(analyzed_fun)
}

# helper function that returns the Github link (in markdown format) for a given
# input file.
getHyperlink <- function(analyzed_file){
    file_ref <- gsub(" ", "", analyzed_file)
    refs <- unlist(strsplit(file_ref, ":"))
    file_hyperlink <- paste(GitHub_repository, "blob", GitHub_head_ref, location, "src", refs[1], sep="/")
    file_hyperlink <- paste0(file_hyperlink, "#L", refs[2])
    file_hyperlink <- gsub("[/]+", "/", file_hyperlink) # remove concatenations of 2 or more "/"
    file_hyperlink <- paste(GitHub_server_url, file_hyperlink, sep="/")

    gh_link <- paste0("[",file_ref,"](",file_hyperlink,")")
}

errors <- sapply(result$logtable,  getErrors)
status <- 0

# print all the errors and return a proper exit status code
if (any(errors)){
    print(result)
    print(result$logtable)


    # extract only the error lines
    error_table <- result[errors]

    # add a column containing the name of the function analyzed
    function_names <- unlist(lapply(error_table$binaryfile, getFunctionName))
    error_table <- cbind(data.table(func=function_names),error_table)
    colnames(error_table)[1] <- "func"

    # extract the first error for each function
    first_error_table <- error_table[,.SD[1], by=func]

    # generate the report file
    report_table <- data.table(function_name=c(), message=c(), file_line=c(), address_trace=c())
    for (i in seq(dim(first_error_table)[1])){
        
        file_line_link <- getHyperlink(first_error_table$logtable[[i]]$file.line[1])
        address_trace_link <- first_error_table$logtable[[i]]$address.trace[1]
        if (address_trace_link != "No Address Trace found"){
            address_trace_link <- getHyperlink(address_trace_link)
        }

        new_row <- data.table(function_name=first_error_table$func[i], message=first_error_table$logtable[[i]]$message[1], 
                            file_line=file_line_link, address_trace=address_trace_link)
        report_table <- rbind(report_table, new_row)
    }

    write(knitr::kable(report_table), file.path(GitHub_workspace, "report.md"))

    if (fail_ci_if_error == "true"){
        status <- 1
    }
}else{
    write("No error has been reported by RcppDeepState", file.path(GitHub_workspace, "report.md"))
}

quit(status=status)  # return an error code