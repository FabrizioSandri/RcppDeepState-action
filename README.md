# RcppDeepState action
This repository contains the implementation of a GitHub Action for RcppDeepState. You can use this Action to launch RcppDeepState in any Rcpp-based projects hosted on GitHub.

RcppDeepState is a fuzz testing library made as a composition of three tools: Rcpp, DeepState and Valgrind. You can use RcppDeepState to fuzz test your R library's C++ code in order to find more subtle bugs like memory leaks or even more general memory errors. 

* Link to [RcppDeepState](https://github.com/FabrizioSandri/RcppDeepState)

## Inputs
-   **location** (default value: `/`) - Relative path under `$GITHUB_WORKSPACE` that contains the package that needs to be analyzed. Default uses the `/` location relative to `$GITHUB_WORKSPACE`, that is `$GITHUB_WORKSPACE`.

## Outputs

## Usage
Before running this GitHub Action it's mandatory to run the [actions/checkout](https://github.com/actions/checkout) Action to check-out the repository containing the Rcpp package that needs to be analyzed. Remember that you must specify the parameter `location` for this action if you use the `path` argument for `actions/checkout` or if the package that has to be analyzed isn't located in the root of the repository, otherwise RcppDeepState won't be able to find your package.

```yaml
- uses: actions/checkout@v2

- uses: FabrizioSandri/RcppDeepState-action
  with:
    # Relative path under $GITHUB_WORKSPACE where the package that needs to be
    # analyzed is located.
    # Default: / 
    location: ''
```

#### Basic example
This simple workflow can be run inside a repository containing a Rcpp-based package, stored in the root of the repository. 
```yaml
- uses: actions/checkout@v2

- uses: FabrizioSandri/RcppDeepState-action
```

#### Custom path example
Assume the package you wish to test is not at the repository's root, but rather, for instance, in the `/inst/testpkgs/testSAN` subdirectory. In this case, the package can be analyzed specifying the `location` parameter. 

```yaml
- uses: actions/checkout@v2

- uses: FabrizioSandri/RcppDeepState-action
  with:
    location: '/inst/testpkgs/testSAN'
```