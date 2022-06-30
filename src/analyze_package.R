require(RcppDeepState)

GitHub_workspace <- Sys.getenv("GITHUB_WORKSPACE")

deepstate_harness_compile_run(GitHub_workspace)
result <- deepstate_harness_analyze_pkg(GitHub_workspace)

print(result)
print(result$logtable)