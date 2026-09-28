# =====================================================================
#  Capture the REAL R console errors for prompt P4
#  BDA400 Assignment 3 - run with:  Rscript R\05_capture_p4_error.R
#
#  This does not invent anything. It runs the unaltered version 1
#  function on the inputs that fail and records the exact text R
#  itself produces, in the same shape RStudio's red console text
#  takes. The record is saved to output/p4_real_error.txt, so the
#  saved evidence is byte-for-byte what R produced, and the same
#  text is printed here.
# =====================================================================

log_file <- file(description = file.path("output", "p4_real_error.txt"),
                open = "wt", encoding = "UTF-8")
sink(log_file, type = "output")

source(file.path("R", "03_ai_version_v1.R"))

show_case <- function(label, call_text, expr) {
  cat("### ", label, "\n", sep = "")
  cat("> ", call_text, "\n", sep = "")
  tryCatch(
    {
      v <- eval(expr)
      cat("NO ERROR. It returned: ", paste(v, collapse = ", "), "\n", sep = "")
    },
    error = function(e) {
      cat("Error in ", paste(deparse(conditionCall(e)), collapse = " "), " : \n", sep = "")
      cat("  ", conditionMessage(e), "\n", sep = "")
    }
  )
  cat("\n")
  invisible(NULL)
}

cat("R version:  ", R.version.string, "\n", sep = "")
cat("Captured by: R/05_capture_p4_error.R\n")
cat("Under test:  R/03_ai_version_v1.R, unaltered\n\n")

# --- the crash: every value missing ---------------------------------
show_case("all values missing",
          "remove_outliers_v1(c(NA, NA, NA))",
          quote(remove_outliers_v1(c(NA, NA, NA))))

# --- the same crash from one missing value, nothing else an outlier --
show_case("one missing value, no outlier present",
          "remove_outliers_v1(c(5, NA, 7, 6, 8))",
          quote(remove_outliers_v1(c(5, NA, 7, 6, 8))))

# --- the wrong type --------------------------------------------------
show_case("text instead of numbers",
          'remove_outliers_v1(c("a", "b", "c"))',
          quote(remove_outliers_v1(c("a", "b", "c"))))

# --- the silent wrong answer: no error at all ------------------------
show_case("missing values plus a real outlier",
          "remove_outliers_v1(c(10, 15, NA, 999, 20, 25, NA))",
          quote(remove_outliers_v1(c(10, 15, NA, 999, 20, 25, NA))))
cat("The 999 was removed, but both NA values came back inside the result\n")
cat("that the function called clean, and nothing warned about it.\n")

sink(type = "output")
close(log_file)

# --- show the saved evidence ----------------------------------------
cat(readLines("output/p4_real_error.txt", warn = FALSE), sep = "\n")
cat("\nSaved to output/p4_real_error.txt\n")
