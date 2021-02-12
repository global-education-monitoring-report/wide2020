# This file includes R scripts developing UNESCO GEMR R package "gemRtools".
# ver. Feb 11, 2020
# Contact: Sunmin Lee, Bilal Barakat

########## Install and load development packages ##########
install.packages("devtools") # make sure to use the most recent R version
install.packages("roxygen2") # package for documentation
library("devtools")
library("roxygen2")

########## Create package directory ##########
setwd("/Users/sunminlee/Desktop/gemr/gemRpackage") # change this path!
create("gemRtools")
# Include new functions under "R" folder. 
# Recommend to make individual .R files for each function.
# Make sure to include annotation in each file. Below function "document()" from library "roxygen2" will auto generate .Rd file under "man" folder.

########## Set working directory for package documentation ##########
setwd("./gemRtools")
document()

########## Install package ##########
setwd("..")
install("gemRtools")

########## Check package ##########
?test_function

########## (OPTIONAL) Install gemRtools via Github ##########
devtools::install_github("gemRtools", "global-education-monitoring-report")
