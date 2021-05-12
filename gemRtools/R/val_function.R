#' A VAL (validation) Function
#'
#' This function validates certain conditions of the variable values.
#' ver. May 11 2021
#' @param var Variable name to be validated from this dataset
#' @keywords wide
#' @export
#' @examples
#' val_function(age)

df <- read.csv(file = '/Users/sunminlee/Desktop/gemr/gemRpackage/microdata/DHS_COD_2013.csv')
View(df)


# super working
val_function <- function(df, var) {
  # condition 1: check negative values
  for (i in 1:nrow(df)){
    if (isTRUE(df$var[i] < 0)){
      print("Check negative values!")
      break
    } else {
      print("All values are greater than or equal to zero")
    }
  }
}






######## BELOW TESTING CODE - TO BE REMOVED ###########
read_function <- function(survey, iso_code3, year) {
  survey <- deparse(substitute(survey))
  iso_code3 <- deparse(substitute(iso_code3))
  year <- deparse(substitute(year))

  # File name from function
  f <- paste0(survey, "_", iso_code3, "_", year, ".csv")

  # Open the dataset that matches the file name
  for (f_path in list.files(path=".", all.files=FALSE)) {
    if (f == f_path) {
      print("Open dataset!")
      micro_data <- read.csv(f)
      View(micro_data)
      break
    } else {
      print("No dataset. Please check the working directory!")
      break
    }
  }

}



# test
dataframe <- data.frame(A=1:10, B=2:11, C=3:12)
fun1 <- function(x, column){
  max(x[,column])
}
fun1(dataframe, "B")
fun1(dataframe, c("B","A"))


val_function <- function(variable) {
  #var <- toString(variable)
  var <- deparse(substitute(variable))
  #var <- enquo(variable)
  print(var)
  # condition 1: check negative values
  for (i in 1:nrow(df)){
    if (df$var[i] >= 0){
      print("positive")
    } else {
      print("negative")
    }
  }
}


for(i in 1:nrow(d)) {
  if(d$value[i] %% 2 == 0){
    d$value[i] <-0
  }
}
d
}




survey <- deparse(substitute(survey))

library(dplyr)
my_summarise <- function(df, group_var) {
  group_var <- enquo(group_var)
  print(group_var)
  df %>%
    group_by(!! group_var) %>%
    summarise(a = mean(a))
}
my_summarise(df, g1)


# this is working
for (i in 1:nrow(df)){
  if (df$age[i] < 0) {
    print("yes")
  } else {
    print("no")
  }
}


# this is working
val_function <- function(variable) {
  # condition 1: check negative values
  for (i in 1:nrow(df)){
    with(df, df$variable[i] <= 0)
  }
}
