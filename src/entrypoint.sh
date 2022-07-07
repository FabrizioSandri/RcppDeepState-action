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

# return the exit status to the action
exit $retVal
