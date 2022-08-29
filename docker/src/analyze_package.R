require(RcppDeepState)
require(data.table)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")
location <- Sys.getenv("INPUT_LOCATION")
seed_input <- Sys.getenv("INPUT_SEED")
max_seconds_per_function <- Sys.getenv("INPUT_MAX_SECONDS_PER_FUNCTION")
max_inputs <- Sys.getenv("INPUT_MAX_INPUTS")
verbose <- if (Sys.getenv("INPUT_VERBOSE") == "true") TRUE else FALSE
fail_ci_if_error <- Sys.getenv("INPUT_FAIL_CI_IF_ERROR")
GitHub_server_url <- Sys.getenv("GITHUB_SERVER_URL")
GitHub_repository <- Sys.getenv("GITHUB_REPOSITORY")
GitHub_head_ref <- Sys.getenv("GITHUB_HEAD_REF")

pull_sha <- Sys.getenv("PULL_SHA")
short_sha <- strtrim(pull_sha, 7)
seed <- if (seed_input != -1) seed_input else as.integer(Sys.time())

# Here is the maximum GitHub's comment length. The original size is 65536,
# however we consider that the remaining 536 characters are reserved for the
# comment identifier(used to identify the comment when updating), the title
# and for the message that will be printed if the message is truncated.
max_comment_size <- 65000
report_file <- file.path(GitHub_workspace, "report.md") 
truncated_file <- file.path(GitHub_workspace, "truncated.md") 
status <- 0 # default exit code status is 0 (success)

package_root <- file.path(GitHub_workspace, location)
description_file <- file.path(package_root, "DESCRIPTION")
if (!file.exists(description_file)) {
  message(paste("ERROR:", location, "doesn't contain a valid package with a",
                 "DESCRIPTION file"))
  exit(1)
}

# parse the DESCRIPTION file in order to get the package name
description_lines <- readLines(description_file)
package_name_line <- description_lines[grepl("^Package:", description_lines)]
package_name <- gsub("Package: ", "", package_name_line[1])

# analyze with RcppDeepState
deepstate_harness_compile_run(package_root, seed=seed, verbose=verbose,
                              time.limit.seconds=max_seconds_per_function)
result <- deepstate_harness_analyze_pkg(package_root, max_inputs=max_inputs,
                                        verbose=verbose)


# Auxiliary function used to get the errors positions for a single file that has
# been analyzed. Each "logtableElement" correspond to a "data.table" instance
# where the second dimension describes the number of columns, whereas the second
# describes the number of errors found.
getErrors <- function(logtableElement) {
  if (!is.data.table(logtableElement)) FALSE else dim(logtableElement)[1]>0
}

# Auxiliary function used to get the number of inputs that generated errors for
# a given batch of analysis results
getErrorsCount <- function(batch){
  sum(unlist(sapply(batch, nrow)) > 0, na.rm = TRUE)
}

getFunctionName <- function(test_path) {
  test_location <- unlist(strsplit(test_path, "/"))
  analyzed_fun <- test_location[length(test_location)-2]
}

# helper function that returns the Github link (in markdown format) for a given
# input file.
getHyperlink <- function(analyzed_file) {
  file_ref <- basename(gsub(" ", "", analyzed_file))
  refs <- unlist(strsplit(file_ref, ":"))

  file_hyperlink <- paste(GitHub_repository, "blob", pull_sha, location, "src", 
                          refs[1], sep="/")
  line_hyperlink <- gsub("[/]+", "/", paste0(file_hyperlink, "#L", refs[2]))
  final_hyperlink <- paste(GitHub_server_url, line_hyperlink, sep="/")

  gh_link <- paste0("[",file_ref,"](",final_hyperlink,")")
}

# Helper function that generates a markdown version of an input list
getInputsMarkdown <- function(inputList) {
  markdown_res <- ""
  for (i in seq(length(inputList))) {
    name <- names(inputList)[i]
    value <- inputList[i]
    markdown_res <- paste0(markdown_res, "<details><summary>", name,
                           "</summary>", value, "</details>")
  }

  markdown_res
}

# Helper function that generates the code for a test given the inputs
getExecutableFile <- function(inputs, function_name) {
  inputList <- paste(capture.output(dput(inputs)), collapse="")
  executable_file <- paste0("testlist <- ", inputList, "<br/>",
                            "result <- do.call(", package_name, ":::",
                            function_name, ", testlist)")
  markdown_res <- paste0("<details>", "<summary>", "Test code", "</summary>",
                         "<pre>", executable_file, "</pre>", "</details>")
}

# This function generates a markdown table from given a data.table using less
# character as possible(avoiding unnecessary spacing) and being withing the
# character limit imposed by 'max_len'
generateMarkdownTable <- function(table, max_len) {
  truncated <- FALSE
  truncated_msg <- paste("The table has been truncated because it exceeds the",
                         "maximum allowed comment size. You can find the full",
                         "markdown table in the artifact file associated to",
                         "this workflow run.")

  column_names <- gsub("_"," ",colnames(table), fixed=TRUE)
  header <- paste0("|", paste(column_names, collapse="|"), "|")
  line_sep <- paste(rep("|", length(column_names) + 1), collapse="-")
  markdown_table <- paste(header, line_sep, sep="\n")

  remaining <- max_len - nchar(markdown_table)

  for (row_i in seq(nrow(table))) {
    markdown_row <- paste0("|", paste(table[row_i], collapse="|"), "|")
    markdown_row <- gsub("\n", "", markdown_row)
    if (nchar(markdown_row) < remaining) {
      markdown_table <- paste(markdown_table, markdown_row, sep="\n")
      remaining <- remaining - nchar(markdown_row) 
    }else {
      truncated <- TRUE
    }
  }

  if (truncated) {
    markdown_table <- paste(markdown_table, truncated_msg, sep="\n\n")
    output_truncated <- paste0("echo ::set-output name=truncated::true")
    system(output_truncated, intern = FALSE)

    # save the full table
    write(knitr::kable(table), truncated_file, append=TRUE)
  }

  markdown_table
}

rcppdeepstate_repo <- "https://github.com/FabrizioSandri/RcppDeepState"
write_to_report <- paste0("## [RcppDeepState](", rcppdeepstate_repo, ") Report")

# add a column containing the name of the function analyzed
analyzed_functions <- unlist(lapply(result$binaryfile, getFunctionName))
analyzed_table <- cbind(data.table(func=analyzed_functions), result)
colnames(analyzed_table)[1] <- "function_name"

# Generate the summary table: contains for each function analyzed, the number of 
# inputs tested and the number of inputs which caused at least one valgrind 
# message/issue
summary_table <- analyzed_table[,.(tested_inputs=.N, 
                 inputs_with_issues=getErrorsCount(logtable)), by=function_name]

summary_header <- "### Analyzed functions summary"
summary_table_md <- generateMarkdownTable(summary_table, max_comment_size)
summary_md <- paste(summary_header, summary_table_md, sep="\n")

max_comment_size <- max_comment_size - nchar(summary_md)

# print all the errors and return a proper exit status code
errors <- sapply(analyzed_table$logtable,  getErrors)
if (any(errors)) {
  print(analyzed_table)
  print(analyzed_table$logtable)

  output_errors <- paste0("echo ::set-output name=errors::true")
  system(output_errors, intern = FALSE)

  # extract only the error lines
  error_table <- analyzed_table[errors]

  # extract the first error for each function
  first_error_table <- error_table[,.SD[1], by=function_name]

  # generate the report file
  report_table <- data.table(function_name=c(), message=c(), file_line=c(),
                             address_trace=c(), R_code=c())
  
  for (i in seq(dim(first_error_table)[1])) {
    
    file_line_link <- getHyperlink(first_error_table$logtable[[i]]$file.line[1])
    address_trace_link <- first_error_table$logtable[[i]]$address.trace[1]
    if (address_trace_link != "No Address Trace found") {
      address_trace_link <- getHyperlink(address_trace_link)
    }

    message <- first_error_table$logtable[[i]]$message[1]
    executable_file <- getExecutableFile(first_error_table$inputs[[i]],
                                         first_error_table$function_name[i])

    new_row <- data.table(function_name=first_error_table$function_name[i],
                          message=message, file_line=file_line_link,
                          address_trace=address_trace_link,
                          R_code=executable_file)
    report_table <- rbind(report_table, new_row)
  }

  report_table_md <- generateMarkdownTable(report_table, max_comment_size)
  write_to_report <- paste(write_to_report, report_table_md, sep="\n")

  if (fail_ci_if_error == "true") {
    status <- 1
  }
}else{
  output_errors <- paste0("echo ::set-output name=errors::false")
  system(output_errors, intern = FALSE)

  no_error_message <- "No error has been reported by RcppDeepState"
  write_to_report <- paste(write_to_report, no_error_message, sep="\n")
}

write_to_report <- paste(write_to_report, summary_md, sep="\n")

# Add to the report the list of parameters used to run the test
commit_sha_md <- paste("Report generated by:", short_sha)
seed_md <- paste("Inputs generator seed:", seed)
parameters_list <- paste("### Report details", commit_sha_md, seed_md,  
                         sep="\n* ")
write_to_report <- paste(write_to_report, parameters_list, sep="\n")

write(write_to_report, report_file, append=FALSE)
quit(status=status) # return an error code
