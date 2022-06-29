#!/bin/bash

### Dependencies installation
Rscript -e 'install.packages("devtools", repos="https://cloud.r-project.org")'
Rscript -e 'devtools::install_github("FabrizioSandri/RcppDeepState")'
