This is a README file that guides developing UNESCO GEMR R package "gemRtools".  
@ Date: Feb 20, 2021 (Updated: Feb 21, 2021)  
@ Contact: Sunmin Lee (sm.lee@unesco.org), Bilal Barakat (bf.barakat@unesco.org)   
<br/>  
***  

## R package: gemRtools
>The R package "gemRtools" developed by UNESCO GEMR team includes several functions that helps to manipulate data.   

As of updated date, the package includes following functions:
* test_function 
<br/>  
*** 
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
Set working directory in your local machine (change the path in below script) and create new project called "gemRtools".
```
<R script>
> setwd("/Users/sunminlee/Desktop/gemr/gemRpackage")
> create("gemRtools")
```
* Include new functions under *R* folder. Recommend to make individual .R files for each function. 
* Make sure to include annotation in each file.

<br/>

### Step 3. Set working directory for package documentation
The function "document()" from library "roxygen2" will auto generate .Rd file under *man* folder.
```
<R script>
> setwd("./gemRtools")
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
This will show preview of function documentation filled in step 2.
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
