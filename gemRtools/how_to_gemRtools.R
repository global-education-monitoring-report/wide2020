# This file includes R scripts developing UNESCO GEMR R package "gemRtools".
# Please also refer to README.md file.
# ver. June 10, 2021

########## Install and load development packages ##########
#install.packages("devtools") # make sure to use the most recent R version
#install.packages("roxygen2") # package for documentation
library("devtools")
library("roxygen2")

########## Create/Set package directory ##########
setwd("/Users/sunminlee/Desktop/gemRtools") # change this path to your working directory
create("gemRtools") # create project if it is first time to do

# Include new functions under "R" folder. 
# Recommend to make individual .R files for each function.
# Make sure to include annotation in each file (refer to test_function.R for the template).

# If you need to install other packages (as dependency) to execute the new function, please specify below.
# This will be integrated in the DESCRIPTION file as "imports" and mandates to pre-install when using gemRtools package.
usethis::use_package("dplyr")

test_function <- function(test=TRUE){
  if(test==TRUE){
    print("Test is successful!")
  }
  else {
    print("Re-test")
  }
}

########## Function to update the documentation automatically ##########
# Below function "document()" from library "roxygen2" will auto generate .Rd file under "man" folder.
document()

########## Install package ##########
setwd("..")
install("gemRtools")

########## Check package ##########
# If installed successfully, you will see function documentation in the right side corner HELP window. 
?test_function 
?read_function # execute ?function one by one

########## (OPTIONAL) Install gemRtools via Github ##########
devtools::install_github("gemRtools", "global-education-monitoring-report")
