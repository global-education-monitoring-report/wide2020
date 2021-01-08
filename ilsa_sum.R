### ilsa_sum: function to summarize ILSA indicators
### January 2021

ilsa_sum <- function(pvnames = "LECT",
                     cutoff = c(399.1, 469.5, 540, 610.4),
                     config = pasec_conf,
                     data = pasec2,
                     year = 2014,
                     level = "Primary",
                     grade = 2,
                     survey = "PASEC",
                     prefix = "r") {

# coerce to df
data <- as.data.frame(data)
  
# groups
vars <- c("Sex", "Location", "Language", "Wealth")
vars <- intersect(names(data), vars)

# % at or above levels

## by country
total <- intsvy.ben.pv(pvnames = pvnames, cutoff= cutoff, by = "COUNTRY", 
                       data = data, config = config)
total <- cbind(total, "category" = "Total")

## by group
one <- lapply(vars, function(x) {
  df = intsvy.ben.pv(pvnames = pvnames, 
                     cutoff = cutoff, by = c("COUNTRY", x), 
                     data = data[complete.cases(data[, x]), ], config = config);
  df$category = x;
  df})

one <- do.call(dplyr::bind_rows, one)

## appended data
bench <- dplyr::bind_rows(total, one)
bench$levels <- factor(bench$Benchmark, 
                       levels = sapply(seq_along(cutoff), function(c) 
                         grep(cutoff[c], levels(factor(bench$Benchmark)), value = TRUE)),
                       labels = paste0("level", 1:length(cutoff)))


# n at or above levels

## pv1 label name for n calculation
pv1 <- grep(pvnames, names(data), value = TRUE)[1]

## binary level indicator based on pv1
ach_level <- paste0(pvnames, "_level", 1:length(cutoff))

data[ach_level] <- as.data.frame(sapply(1:length(cutoff), function(x) 
  cut(data[[pv1]], breaks = c(-Inf, cutoff[x], + Inf), labels = FALSE) -1))

## n at or above levels by country
total_n <- aggregate(data[ach_level], by=list(COUNTRY = data[["COUNTRY"]]), sum)
total_n <- cbind(total_n, "category"= "Total")


one_n <- lapply(vars, function(x) {
  df = aggregate(data[ach_level], by=data[, c("COUNTRY", x)], sum);
  df$category = x;
  df})

one_n <- do.call(dplyr::bind_rows, one_n)

## appended data
bench_n <- dplyr::bind_rows(total_n, one_n)

## WIDE data structure
bench_n <- pivot_longer(data = bench_n, 
                        cols = starts_with(paste0(pvnames, "_")), 
                        names_prefix = paste0(pvnames, "_"),
                        names_to = "levels", values_to = "n",
                        values_drop_na = TRUE)



# merge n and % data
bench_tot <- left_join(bench, bench_n, by = c("COUNTRY", "category", vars, "levels"))


# output
myout <- pivot_wider(data = bench_tot, 
                     id_cols = c("COUNTRY", "category", all_of(vars)),
                     names_from= c("levels"), values_from =c("Percentage", "Std. err.", "n"))

## var names

perlev <- paste0(prefix, "level", 1:length(cutoff), "_m")
selev <- paste0(prefix, "level", 1:length(cutoff), "_se")
nolev <- paste0(prefix, "level", 1:length(cutoff), "_no")

names(myout) <- c("COUNTRY", "category", vars, perlev, selev, nolev)

## divide by 100
pervars <- grep("_m|_se", names(myout), value = TRUE)
myout[pervars] <- myout[pervars]/100

## add survey variables
myout <- cbind(myout, "year"=year, "grade"=grade, "level"=level, "survey" =  survey)
return(myout)
}
