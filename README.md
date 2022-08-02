# RcppDeepState action
This repository contains the implementation of a GitHub Action for RcppDeepState. You can use this Action to launch RcppDeepState in any Rcpp-based projects hosted on GitHub.

RcppDeepState is a fuzz testing library made as a composition of three tools: Rcpp, DeepState and Valgrind. You can use RcppDeepState to fuzz test your R library's C++ code in order to find more subtle bugs like memory leaks or even more general memory errors. 

* Link to [RcppDeepState](https://github.com/FabrizioSandri/RcppDeepState)

## Inputs
-   **fail_ci_if_error** (default value: `false`) - Specify if CI pipeline should fail when RcppDeepState finds errors;
-   **location** (default value: `/`) - Relative path under `$GITHUB_WORKSPACE` that contains the package that needs to be analyzed. Default uses the `/` location relative to `$GITHUB_WORKSPACE`, that is `$GITHUB_WORKSPACE`;
-   **seed** (default value: `-1`) - control the randomness of the inputs generated in the fuzzing phase;
-   **time_limit** (default value: `5`) - Fuzzing phase's duration in seconds;
-   **max_inputs** (default value: `3`) - Maximum number of inputs that will be processed by RcppDeepState;
-   **comment** (default value: `false`) - Print the analysis results as a comment if run in a pull request. If set to `failure` only writes a comment if RcppDeepState discovers at least one issue;
-   **verbose** (default value: `false`) - Enables verbose logging of RcppDeepState.

## Outputs

## Usage
There are two ways to initialize this action inside a repository:
1. Create a workflow file manually in the `.github/workflows` folder using the model shown below; 
2. Automatically generate the workflow files using the `ci_setup` function of RcppDeepState

Before running this GitHub Action it's mandatory to run the [actions/checkout](https://github.com/actions/checkout) Action to check-out the repository containing the Rcpp package that needs to be analyzed. Remember that you must specify the parameter `location` for this action if you use the `path` argument for `actions/checkout` or if the package that has to be analyzed isn't located in the root of the repository, otherwise RcppDeepState won't be able to find your package.

```yaml
- uses: actions/checkout@v2

- uses: FabrizioSandri/RcppDeepState-action
  with:

    # This parameter is used to specify if the CI pipeline should fail when 
    # RcppDeepState finds at least one error.
    # Default: 'false'
    fail_ci_if_error: ''

    # Relative path under $GITHUB_WORKSPACE where the package that needs to be
    # analyzed is located.
    # Default: / 
    location: ''

    # Seed value used to control the randomness of the inputs generated in the 
    # fuzzing phase. This parameter is used to run deterministic fuzz testing 
    # and reproduce the analysis results over several executions. A value of -1
    # is used to generate a random value. 
    # Default: -1
    seed: ''

    # This parameter controls the fuzzing phase's duration in seconds. 
    # Default: 5
    time_limit: ''

    # Maximum number of inputs that will be processed by RcppDeepState. The 
    # fuzzing phase may generate a lot of inputs, however analyzing all of them
    # can require a huge amount of time, making this task almost impossible.
    # Instead by using this parameter it is possible to control the number of 
    # inputs analyzed by RcppDeepState for each tested function. 
    # Default: 3
    max_inputs: ''

    # If this action is used inside a pull request's pipeline, this parameter
    # control whether the analysis result should be printed as a comment in the 
    # pull request. This parameter can be set to 'failure' to write comments
    # only if RcppDeepState discovers at least one issue.  
    # Default: 'false'
    comment: ''
    
    # This parameter enables the verbose logging mode of RcppDeepState. If set 
    # to 'true' RcppDeepState will print more debugging information. If set to
    # 'false' only the analysis result will be printed on the standard output.
    # Default: 'false'
    verbose: ''
```

#### Basic example
This simple workflow can be run inside a repository containing a Rcpp-based package, stored in the root of the repository. Once a push events is triggered inside a pull request this workflow will be run and a comment with the analysis report will be added to the pull request. 
```yaml
on:
  pull_request:
    branches: 
      - '*'

name: "Analyze package with RcppDeepState"

jobs:
  RcppDeepState:
    runs-on: ubuntu-latest
    
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      
    steps:      
      - uses: actions/checkout@v2 

      - uses:  FabrizioSandri/RcppDeepState-action@main
        with:
          comment: 'true'
```

#### Custom path example
Assume the package you wish to test is not at the repository's root, but rather, for instance, in the `/inst/testpkgs/testSAN` subdirectory. In this case, the package can be analyzed specifying the `location` parameter. 

```yaml
on:
  pull_request:
    branches: 
      - '*'

name: "Analyze package with RcppDeepState"

jobs:
  RcppDeepState:
    runs-on: ubuntu-latest
    
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      
    steps:      
      - uses: actions/checkout@v2 

      - uses:  FabrizioSandri/RcppDeepState-action@main
        with:
          location: '/inst/testpkgs/testSAN'
          comment: 'true'
```

#### CI fail example
If you want to make the RcppDeepState workflow fail if at least one error is found you have to set the `fail_ci_if_error` parameter to `true`. In this manner, if an error is found, the workflow will fail and an a :x: symbol will be displayed.

The example in the next lines of code executes RcppDeepState on a package that is saved at the root of the repository, and if at least one problem is discovered, the workflow fails. 

```yaml
on:
  pull_request:
    branches: 
      - '*'

name: "Analyze package with RcppDeepState"

jobs:
  RcppDeepState:
    runs-on: ubuntu-latest
    
    env:
      GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
      
    steps:      
      - uses: actions/checkout@v2 

      - uses:  FabrizioSandri/RcppDeepState-action@main
        with:
          fail_ci_if_error: 'true'
          comment: 'true'
```