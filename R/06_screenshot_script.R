# =====================================================================
#  THE COMMANDS BEHIND EACH SCREENSHOT
#  BDA400 Assignment 3
#
#  HOW TO USE IT (in RStudio)
#    1.  File > Open Project... > Assignment3.Rproj
#    2.  Open this file and click Source. Each step below says what
#        to run and what to screenshot.
#    3.  For the steps that say "type this in the console", click in
#        the Console pane and type the exact line shown.
#    4.  Win + Shift + S to snip the RStudio window, save into
#        screenshots\ under the name the report expects
#        (see screenshots\README.md).
# =====================================================================

cat("========================================================\n")
cat("R ", as.character(getRversion()), " | ", R.version$platform, "\n", sep = "")
cat("Working folder: ", getwd(), "\n", sep = "")
cat("This must end in 'Datascience tools assign-3'.\n")
cat("If it does not, open the RStudio *project* first, not the file.\n")
cat("========================================================\n")

# --- load everything, in the order the final report used ------------
source(file.path("R", "01_synthetic_data.R"))   # the synthetic data
source(file.path("R", "02_remove_outliers_final.R"))  # the final function
source(file.path("R", "03_ai_version_v1.R"))    # version 1, unaltered
source(file.path("R", "04_test_and_verify.R"))  # tests, cross-checks, output files

step <- function(n, title, job) {
  cat("\n\n--------------------------------------------------------\n")
  cat("STEP ", n, " | ", title, "\n", sep = "")
  cat("WHAT TO DO:  ", job, "\n", sep = "")
  cat("--------------------------------------------------------\n")
}

step(1, "R version and working folder",
     "screenshot the console: it proves the tests ran from the project folder.")
cat("(the two lines printed at the top are what you want)\n")

step(2, "the synthetic data table",
     "screenshot the values of the revenue vector used for the cross-check.")
cat("head(synthetic_revenue)\n")
print(head(synthetic_revenue))

step(3, "the AI version 1 function, as ChatGPT wrote it",
     "screenshot the console; the function body printed below is version 1, unaltered.")
print(remove_outliers_v1)

step(4, "DEFECT 2 - the real error prompt P4 asked about",
     "type this line in the console and screenshot the RED text:\n        remove_outliers_v1(c(NA, NA, NA))")
step(4.1, "DEFECT 2b - the second error, text input",
     "type this line in the console and screenshot the RED text:\n        remove_outliers_v1(c(\"a\", \"b\", \"c\"))")

step(5, "DEFECT 1 - version 1 silently returns NA",
     "type the line below and screenshot the console showing NO error above the result:\n        remove_outliers_v1(c(10, 15, NA, 999, 20, 25, NA))")
cat("Expected result (for your own reference): 10, 15, NA, 20, 25, NA\n")

step(6, "the final version passes the whole suite",
     "screenshot the end of the automated run: 14 of 14 PASS, 0 FAIL.")
cat("suite_df: ", nrow(suite_df), " cases, ",
    sum(suite_df$verdict == "PASS"), " PASS, ",
    sum(suite_df$verdict == "FAIL"), " FAIL\n", sep = "")

step(7, "the independent cross-check against boxplot.stats()",
     "screenshot the agreement table below: method tukey vs R's own function.")
print(comparison)

step(8, "the boxplot before and after",
     "a plot appears in the Plots pane. Screenshot it.")
oldpar <- par(no.readonly = TRUE)
par(mfrow = c(1, 2))
boxplot(synthetic_revenue, main = "Revenue, as given", ylab = "Revenue", col = "grey85")
boxplot(synthetic_revenue, main = "After remove_outliers()", ylab = "Revenue", col = "grey85")
par(oldpar)

cat("\n\nDONE. Screenshots to take: one per STEP, plus the plot from STEP 8.\n")
cat("Save them into screenshots\\ using the names in screenshots\\README.md.\n")