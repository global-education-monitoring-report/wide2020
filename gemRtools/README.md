This is a README file that guides developing UNESCO GEMR R package "gemRtools".  
@ Date: Feb 20, 2021 (Updated: June 10, 2021)  
<br/>  
***  

## R package: gemRtools
>The R package "gemRtools" developed by UNESCO GEMR team includes several functions that helps to manipulate data.   

As of updated date, the package includes following functions:
* test_function (this .R file includes template to follow)
* read_function
* val_function
* category_arrange
* update_income_groups 
<br/>  

## Developing "gemRtools" Step by Step
### Step 1. Install and load development packages
Make sure to use the most recent version of R and R studio. Install following packages and load for development. Note that package "devtools" could take some time to install. The package "roxygen2" is for documentation purpose.

```
<R script>
> install.packages("devtools")
> install.packages("roxygen2")
> library("devtools")
> library("roxygen2")
```
<br/>

### Step 2. Create package directory
Set working directory in your local machine (change the path in below script) and create new project called "gemRtools" if it is first time to initiate the project. If it is not first time, this step can be skipped.
```
<R script>
> setwd("/Users/sunminlee/Desktop/gemRtools")
> create("gemRtools")
```
* Include new functions under *R* folder. Recommend to make individual .R files for each function. 
* Make sure to include annotation in each file (refer to test_function.R for the template).
```
<R script>
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
```

<br/>

### Step 3. Set working directory for package documentation
The function "document()" from library "roxygen2" will auto generate .Rd file under *man* folder and update the "imports" dependencies in the DESCRIPTION file.
```
<R script>
> document()
```
<br/>

### Step 4. Install package
```
<R script>
> setwd("..")
> install("gemRtools")
```
<br/>

### Step 5. Check package and functions
This will show preview of function documentation filled in step 2 in the right corner HELP window.
```
<R script>
> ?test_function
```
<br/>

### Optional: Install "gemRtools" via Github
```
<R script>
> devtools::install_github("gemRtools", "global-education-monitoring-report")
```

### References
* Also refer to "how_to_gemRtools.R" file for detail scripts.
* [Devtools Package Development CheatSheet] (https://rawgit.com/rstudio/cheatsheets/master/package-development.pdf)
* [Writing R Package from Scratch] (https://hilaryparker.com/2014/04/29/writing-an-r-package-from-scratch/)
* [R Package Metadata] (https://r-pkgs.org/description.html#dependencies)
* [Updated content of R Package Metadata] (https://github.com/hadley/r-pkgs/blob/master/metadata.Rmd#L105)
