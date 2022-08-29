#!/bin/bash

# disable optimization options
mkdir -p ~/.R
echo -e "CXXFLAGS = \nCXX11FLAGS = \nCXX14FLAGS = \nCXX17FLAGS = \nCXX20FLAGS = \n" > ~/.R/Makevars

### Start the analysis
echo "RcppDeepState analysis started..."

Rscript "/analyze_package.R"
retVal=$?

echo "RcppDeepState analysis completed"

# remove vgcore files and adjust permissions
find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -maxdepth 2 -name 'vgcore*' | xargs -r rm

find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type d | xargs -r chmod 755;
find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type f | xargs -r chmod 644;

# return the exit status to the action
exit $retVal
