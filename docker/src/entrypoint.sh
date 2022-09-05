#!/bin/bash

# install extra dependencies
echo "::group::System dependencies setup"
if [ -z $INPUT_ADDITIONAL_DEPENDENCIES ]; then
  echo "No extra dependency provided."
else
  echo "Installing extra dependencies: ${INPUT_ADDITIONAL_DEPENDENCIES} "
  apt install -y $INPUT_ADDITIONAL_DEPENDENCIES
fi
echo "::endgroup::"

# disable optimization options
mkdir -p ~/.R
echo -e "CXXFLAGS = \nCXX11FLAGS = \nCXX14FLAGS = \nCXX17FLAGS = \nCXX20FLAGS = \n" > ~/.R/Makevars

### Start the analysis
Rscript "/analyze_package.R"
retVal=$?

# remove vgcore files and adjust permissions
find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -maxdepth 2 -name 'vgcore*' | xargs -r rm

find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type d | xargs -r chmod 755;
find "$GITHUB_WORKSPACE/$INPUT_LOCATION/inst/testfiles" -type f | xargs -r chmod 644;

# return the exit status to the action
exit $retVal
