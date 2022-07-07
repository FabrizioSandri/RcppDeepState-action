require(RcppDeepState)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")
location <- Sys.getenv("INPUT_LOCATION")

deepstate_harness_compile_run(file.path(GitHub_workspace, location))
result <- deepstate_harness_analyze_pkg(file.path(GitHub_workspace, location))

print(result)
print(result$logtable)