#!/bin/bash

### Dependencies installation
Rscript -e 'install.packages("devtools", repos="https://cloud.r-project.org")'
Rscript -e 'devtools::install_github("FabrizioSandri/RcppDeepState")'

# disable optimization options
mkdir -p ~/.R
echo -e "CXXFLAGS = \nCXX11FLAGS = \nCXX14FLAGS = \nCXX17FLAGS = \nCXX20FLAGS = \n" > ~/.R/Makevars

### Start the analysis
echo "RcppDeepState analysis started..."

Rscript "/analyze_package.R"
retVal=$?

echo "RcppDeepState analysis completed"

# remove vgcore files and adjust permissions
find . -name 'vgcore*' | xargs rm

find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type d -exec chmod 755 {} \;
find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type f -exec chmod 644 {} \;

# return the exit status to the action
exit $retVal
