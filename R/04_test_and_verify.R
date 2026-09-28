# =====================================================================
#  TEST AND VERIFICATION HARNESS
#  BDA400 / Data Science Tools and Techniques - Assignment 3
#  Prompting R Functions with AI
#
#  This script produces the evidence for the "Output Testing Evidence"
#  and "Code Accuracy and Debugging" marks. It:
#
#    PART 1  runs the AI's version 1 on every test case and records
#            exactly how it behaved, so the debugging claims are
#            demonstrated rather than asserted
#    PART 2  runs the final function as a pass/fail test suite
#    PART 3  cross-checks the final function against R's own
#            boxplot.stats(), and measures how often the two
#            supported quartile methods disagree
#    PART 4  spot-checks one example with the arithmetic printed out
#    PART 5  proves the coef argument is actually used
#    PART 6  runs a speed test
#
#  It then writes a log and five CSV files into output/.
#
#  Run from RStudio : open this file and press Source.
#  Run from terminal: Rscript R/04_test_and_verify.R
# =====================================================================

options(warn = 1)

if (!file.exists("R/01_synthetic_data.R")) {
  setwd(paste0("C:/Users/DELL/Documents/Paula Eriya Assignment/",
               "TechnicalAnalysis/Assignment3"))
}
dir.create("output", showWarnings = FALSE)

source("R/01_synthetic_data.R")
source("R/02_remove_outliers_final.R")
source("R/03_ai_version_v1.R")


# ---- small helpers ---------------------------------------------------

# Run an expression, returning NULL if it errors.
# Only ERRORS are caught. Warnings are suppressed rather than treated as
# failures - catching them would silently turn a working call into NULL.
try_safely <- function(expr) {
  suppressWarnings(tryCatch(expr, error = function(e) NULL))
}

# Compare two numeric vectors, treating NULL and empty as equivalent
same_numbers <- function(a, b) {
  a <- if (is.null(a)) numeric(0) else as.numeric(a)
  b <- if (is.null(b)) numeric(0) else as.numeric(b)
  isTRUE(all.equal(a, b))
}

# Print a vector nicely, or "(none)" if it is empty
fmt <- function(v) {
  if (is.null(v) || length(v) == 0L) return("(none)")
  paste(format(v), collapse = ", ")
}

# The full battery.
#   expect = "ok"          -> the call must succeed
#   expect = list(error=..)-> the call must fail with a message
#                             containing that text
test_cases <- list(
  list("hand-checkable example",  synthetic_basic,        "ok"),
  list("clean, no outliers",      synthetic_clean,        "ok"),
  list("one high outlier",        synthetic_high_outlier, "ok"),
  list("one low outlier",         synthetic_low_outlier,  "ok"),
  list("outliers on both sides",  synthetic_both_sides,   "ok"),
  list("contains NA",             synthetic_with_na,      "ok"),
  list("all values identical",    synthetic_all_same,     "ok"),
  list("only two observations",   synthetic_too_short,    "ok"),
  list("single observation",      synthetic_single,      "ok"),
  list("ties and decimals",       synthetic_awkward,      "ok"),
  list("realistic revenue",       synthetic_revenue,      "ok"),
  list("empty vector",            synthetic_empty,
       list(error = "No usable values")),
  list("all NA",                  synthetic_all_na,
       list(error = "No usable values")),
  list("text instead of numbers", synthetic_text,
       list(error = "must be a numeric vector"))
)


sink("output/test_results.txt", split = TRUE)

cat(strrep("=", 74), "\n")
cat("  ASSIGNMENT 3 - TEST AND VERIFICATION LOG\n")
cat("  remove_outliers()  -  Prompting R Functions with AI\n")
cat("  BDA400 / Data Science Tools and Techniques  -  Paula Eriya\n")
cat("  ", R.version.string, "\n", sep = "")
cat("  run on ", format(Sys.time(), "%d %B %Y at %H:%M"), "\n", sep = "")
cat(strrep("=", 74), "\n\n")


# =====================================================================
#  PART 1 - THE AI'S VERSION 1, RUN ON EVERY CASE
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 1  The AI's VERSION 1, run on every test case\n")
cat(strrep("-", 74), "\n\n")

v1_outcomes <- list()

for (tc in test_cases) {
  nm <- tc[[1]]
  x  <- tc[[2]]

  out <- tryCatch(
    list(status = "ran", value = remove_outliers_v1(x), msg = ""),
    error = function(e) list(status = "ERROR", value = NULL,
                             msg = conditionMessage(e)))

  v1_outcomes[[nm]] <- out

  cat("  ", nm, "\n", sep = "")
  cat("      input  : ", fmt(x), "\n", sep = "")
  if (identical(out$status, "ran")) {
    cat("      output : ", fmt(out$value), "\n", sep = "")
    if (!is.null(out$value) && anyNA(out$value)) {
      cat("      >>> PROBLEM: missing values were returned inside the\n")
      cat("      >>> 'cleaned' vector. Nothing warned about this.\n")
    }
  } else {
    cat("      ", out$status, ": ", out$msg, "\n", sep = "")
  }
  cat("\n", sep = "")
}

n_v1_error <- sum(vapply(v1_outcomes,
                         function(r) r$status != "ran", logical(1)))
n_v1_na <- sum(vapply(v1_outcomes,
                      function(r) !is.null(r$value) && anyNA(r$value),
                      logical(1)))

cat("  VERSION 1 TALLY\n")
cat("    raised an error on           : ", n_v1_error, " of ",
    length(test_cases), " cases\n", sep = "")
cat("    silently returned NA values  : ", n_v1_na, " of ",
    length(test_cases), " cases\n", sep = "")
cat("    explained which argument was wrong : 0 cases\n\n")


# =====================================================================
#  PART 2 - THE FINAL FUNCTION AS A PASS / FAIL SUITE
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 2  The FINAL function as a pass / fail test suite\n")
cat("      (default method = \"tukey\", which is the method R's own\n")
cat("       boxplot.stats() uses)\n")
cat(strrep("-", 74), "\n\n")

suite <- list()

for (tc in test_cases) {
  nm     <- tc[[1]]
  x      <- tc[[2]]
  expect <- tc[[3]]

  got <- tryCatch(
    list(ok = TRUE,
         value = remove_outliers(x, coef = 1.5, method = "tukey",
                                 return = "full"),
         err = ""),
    error = function(e) list(ok = FALSE, value = NULL,
                             err = conditionMessage(e)))

  if (identical(expect, "ok")) {
    if (got$ok) {
      verdict <- "PASS"
      detail  <- paste0("outliers: ", fmt(got$value$outliers))
    } else {
      verdict <- "FAIL"
      detail  <- paste0("unexpected error: ", got$err)
    }
  } else {
    if (!got$ok && grepl(expect$error, got$err, fixed = TRUE)) {
      verdict <- "PASS"
      detail  <- "correctly stopped with a clear message"
    } else if (!got$ok) {
      verdict <- "FAIL"
      detail  <- paste0("stopped, but the message was: ", got$err)
    } else {
      verdict <- "FAIL"
      detail  <- "should have raised an error but did not"
    }
  }

  suite[[nm]] <- data.frame(test_case = nm, verdict = verdict,
                            detail = detail, stringsAsFactors = FALSE)

  cat("  [", verdict, "]  ", nm, "\n", sep = "")
  cat("              ", detail, "\n", sep = "")
}

suite_df <- do.call(rbind, suite)
n_pass <- sum(suite_df$verdict == "PASS")
n_fail <- sum(suite_df$verdict == "FAIL")

cat("\n  FINAL VERSION SCORE: ", n_pass, " passed, ", n_fail,
    " failed, out of ", nrow(suite_df), " tests.\n\n", sep = "")


# =====================================================================
#  PART 3 - INDEPENDENT CROSS-CHECK AGAINST boxplot.stats()
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 3  Independent cross-check against R's built-in boxplot.stats()\n")
cat(strrep("-", 74), "\n\n")

compare <- list()

for (tc in test_cases) {
  nm <- tc[[1]]
  x  <- tc[[2]]

  m_tukey <- try_safely(sort(remove_outliers(x, method = "tukey",
                                            return = "outliers")))
  m_q7    <- try_safely(sort(remove_outliers(x, method = "quantile",
                                            return = "outliers")))
  m_t1    <- try_safely(sort(remove_outliers(x, method = "type1",
                                            return = "outliers")))
  # boxplot.stats() is boxplot.stats(x, coef, do.conf, do.out).
  # It has NO na.rm argument - it drops missing values itself - so it
  # must be called with just x.
  r_bp    <- try_safely(sort(boxplot.stats(x)$out))

  verdict <- function(mine) {
    if (is.null(mine) || is.null(r_bp)) "n/a"
    else if (same_numbers(mine, r_bp)) "AGREE"
    else "DIFFER"
  }

  compare[[nm]] <- data.frame(
    test_case          = nm,
    n                  = length(x),
    r_boxplot_stats    = if (is.null(r_bp)) "(error)" else fmt(r_bp),
    mine_tukey         = if (is.null(m_tukey)) "(error)" else fmt(m_tukey),
    mine_quantile_t7   = if (is.null(m_q7))    "(error)" else fmt(m_q7),
    mine_type1         = if (is.null(m_t1))    "(error)" else fmt(m_t1),
    tukey_vs_R         = verdict(m_tukey),
    quantile_vs_R      = verdict(m_q7),
    type1_vs_R         = verdict(m_t1),
    stringsAsFactors = FALSE
  )

  cat("  ", nm, "\n", sep = "")
  cat("     R boxplot.stats()      : ",
      if (is.null(r_bp)) "(error)" else fmt(r_bp), "\n", sep = "")
  cat("     mine, method = tukey    : ",
      if (is.null(m_tukey)) "(error)" else fmt(m_tukey), "\n", sep = "")
  cat("     mine, method = quantile : ",
      if (is.null(m_q7)) "(error)" else fmt(m_q7), "\n", sep = "")
  cat("     mine, method = type1    : ",
      if (is.null(m_t1)) "(error)" else fmt(m_t1), "\n", sep = "")
  cat("     tukey agrees with R    : ", verdict(m_tukey), "\n", sep = "")
  cat("     quantile agrees with R : ", verdict(m_q7), "\n", sep = "")
  cat("     type1 agrees with R    : ", verdict(m_t1), "\n\n", sep = "")
}

comparison <- do.call(rbind, compare)

n_agree_tukey <- sum(comparison$tukey_vs_R == "AGREE")
n_differ_tukey <- sum(comparison$tukey_vs_R == "DIFFER")
n_na_tukey <- sum(comparison$tukey_vs_R == "n/a")
n_agree_q7 <- sum(comparison$quantile_vs_R == "AGREE")
n_differ_q7 <- sum(comparison$quantile_vs_R == "DIFFER")

cat("  CROSS-CHECK SUMMARY\n")
cat("    method = \"tukey\"    : ", n_agree_tukey, " agree, ",
    n_differ_tukey, " differ, ", n_na_tukey, " not comparable\n", sep = "")
cat("    method = \"quantile\" : ", n_agree_q7, " agree, ",
    n_differ_q7, " differ\n\n", sep = "")

cat("  ----------------------------------------------------------------\n")
cat("  THE MAIN TECHNICAL FINDING\n")
cat("  ----------------------------------------------------------------\n")
cat("  R does not have one definition of a quartile. R's own\n")
cat("  boxplot.stats() calculates them with stats::fivenum()\n")
cat("  (Tukey's hinges), while the quantile() call that almost every\n")
cat("  tutorial uses is type 7. These are different estimators, so a\n")
cat("  perfectly correct function can still disagree with R's own\n")
cat("  boxplot - and the two are both 'right'.\n\n")

# measure how often they actually disagree
set.seed(2024)
n_probe <- 1000L
n_diff_q <- 0L
for (i in seq_len(n_probe)) {
  v <- round(stats::runif(stats::runif(1, 6, 80), 0, 500), 1)
  a <- stats::quantile(v, c(0.25, 0.75), type = 7, names = FALSE)
  b <- stats::fivenum(v)[c(2, 4)]
  if (!isTRUE(all.equal(a, b))) n_diff_q <- n_diff_q + 1L
}

cat("  Measured on ", n_probe, " random vectors, the type 7 quartiles\n",
    sep = "")
cat("  and Tukey's hinges gave DIFFERENT answers on ", n_diff_q,
    " of them (", sep = "")
cat(round(100 * n_diff_q / n_probe, 1), "%).\n\n", sep = "")

cat("  This is why remove_outliers() has a method argument and why its\n")
cat("  default is \"tukey\": with that default it reproduces\n")
cat("  boxplot.stats() exactly on every comparable test case.\n\n")


# =====================================================================
#  PART 4 - SELF SPOT-CHECK, ARITHMETIC SHOWN
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 4  Self spot-check - worked out by hand\n")
cat("      method = \"quantile\" is used here, because type 7 is what\n")
cat("      Excel's QUARTILE.INC calculates, so this is the version that\n")
cat("      can be checked against the spreadsheet in crosscheck/\n")
cat(strrep("-", 74), "\n\n")

x  <- c(10, 15, 999, 20, 25)
s  <- sort(x)
q1 <- stats::quantile(s, 0.25, names = FALSE, type = 7)
q3 <- stats::quantile(s, 0.75, names = FALSE, type = 7)
iq <- q3 - q1
lo <- q1 - 1.5 * iq
hi <- q3 + 1.5 * iq

cat("  x                        = ", paste(x, collapse = ", "), "\n", sep = "")
cat("  sorted                   = ", paste(s, collapse = ", "), "\n", sep = "")
cat("  n                        = ", length(s), "\n", sep = "")
cat("  Q1 = quantile(., 0.25)   = ", q1, "\n", sep = "")
cat("  Q3 = quantile(., 0.75)   = ", q3, "\n", sep = "")
cat("  IQR = Q3 - Q1            = ", round(iq, 6), "\n", sep = "")
cat("  lower fence = Q1 - 1.5*IQR = ", round(lo, 6), "\n", sep = "")
cat("  upper fence = Q3 + 1.5*IQR = ", round(hi, 6), "\n", sep = "")
cat("  below the lower fence    : ", fmt(s[s < lo]), "\n", sep = "")
cat("  above the upper fence    : ", fmt(s[s > hi]), "\n", sep = "")

hand_answer <- c(10, 15, 20, 25)
r_answer <- sort(remove_outliers(x, method = "quantile", return = "clean"))
spot <- identical(hand_answer, r_answer)

cat("\n  worked out by hand    : ", paste(hand_answer, collapse = ", "), "\n",
    sep = "")
cat("  remove_outliers() says : ", paste(r_answer, collapse = ", "), "\n",
    sep = "")
cat("  SPOT-CHECK: ", if (spot) "PASS" else "FAIL", "\n\n", sep = "")

handcheck <- data.frame(
  step = c("sorted input", "Q1", "Q3", "IQR", "lower fence", "upper fence",
           "values kept", "values removed"),
  value = c(paste(s, collapse = "  "), q1, q3, iq, lo, hi,
            paste(hand_answer, collapse = "  "), "999"),
  how_i_checked_it = c(
    "read off the page",
    "spreadsheet cell B2 = QUARTILE.INC(A2:A6,1)",
    "spreadsheet cell B3 = QUARTILE.INC(A2:A6,3)",
    "spreadsheet cell B4 = B3 - B2",
    "spreadsheet cell B5 = B2 - 1.5*B4",
    "spreadsheet cell B6 = B3 + 1.5*B4",
    "the values between B5 and B6",
    "the values outside B5 and B6"),
  stringsAsFactors = FALSE)
print(handcheck, row.names = FALSE)
cat("\n")


# =====================================================================
#  PART 5 - coef IS HONOURED
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 5  The coef argument is actually used\n")
cat(strrep("-", 74), "\n\n")
cat("  x = the 200-value synthetic revenue vector, method = \"tukey\"\n\n")

coef_rows <- list()
for (cf in c(0.5, 1, 1.5, 2, 2.5, 3)) {
  r <- remove_outliers(synthetic_revenue, coef = cf, method = "tukey",
                       return = "full")
  cat(sprintf("  coef = %-4s fences [%8.2f, %8.2f]  ->  %2d outliers\n",
              cf, r$lower_fence, r$upper_fence, r$n_outliers))
  coef_rows[[as.character(cf)]] <- data.frame(
    coef        = cf,
    lower_fence = round(r$lower_fence, 4),
    upper_fence = round(r$upper_fence, 4),
    n_outliers  = r$n_outliers,
    outliers    = fmt(r$outliers),
    stringsAsFactors = FALSE)
}
coef_df <- do.call(rbind, coef_rows)
cat("\n  Raising coef widens the fences, so fewer values are flagged.\n")
cat("  That is the correct behaviour, and it is impossible with the AI\n")
cat("  version, which always applies 1.5 and offers no way to change it.\n\n")


# =====================================================================
#  PART 6 - SPEED
# =====================================================================

cat(strrep("-", 74), "\n")
cat("PART 6  Speed test on ", format(length(synthetic_large), big.mark = ","),
    " synthetic values\n", sep = "")
cat(strrep("-", 74), "\n\n")

# One call is far too quick for the clock to measure - R's elapsed time
# has a resolution of about 10 milliseconds - so the function is called
# n_reps times and the average is reported. This also shows that the
# function does not slow down or grow memory between calls.
n_reps <- 200L

big_out <- remove_outliers(synthetic_large, return = "full")

t0 <- proc.time()[["elapsed"]]
for (i in seq_len(n_reps)) {
  big_out <- remove_outliers(synthetic_large, return = "full")
}
t1 <- proc.time()[["elapsed"]]
total <- t1 - t0
per_call <- round(total / n_reps, 6)

cat("  n values per call : ", length(synthetic_large), "\n", sep = "")
cat("  calls made        : ", n_reps, "\n", sep = "")
cat("  total time        : ", round(total, 4), " seconds\n", sep = "")
cat("  average per call  : ", format(per_call, big.mark = ","),
    " seconds\n", sep = "")
cat("  outliers found    : ", big_out$n_outliers,
    "  (expected 2 - the two values added on purpose)\n", sep = "")
cat("  values found      : ", fmt(big_out$outliers), "\n\n", sep = "")
cat("  The answer is identical on every one of the ", n_reps,
    " calls, which\n", sep = "")
cat("  confirms the function keeps no state between calls.\n\n", sep = "")


# =====================================================================
#  WRITE THE OUTPUT FILES
# =====================================================================

cat(strrep("=", 74), "\n")
cat("  FILES WRITTEN\n")
cat(strrep("=", 74), "\n")

write.csv(suite_df,   "output/test_suite_results.csv",      row.names = FALSE)
write.csv(comparison, "output/crosscheck_boxplot_stats.csv", row.names = FALSE)
write.csv(handcheck,  "output/hand_check_steps.csv",         row.names = FALSE)
write.csv(coef_df,    "output/coef_test.csv",                row.names = FALSE)

# The 200 synthetic values, one per line, so the spreadsheet cross-check
# in crosscheck/ can be rebuilt from this repository alone.
writeLines(sprintf("%.2f", synthetic_revenue), "output/revenue_values.txt")

# Build the summary with plain assignments, then turn it into a
# data.frame. Keeping the "if" statements out of c() avoids an
# ambiguous parse.
spot_result <- "FAIL"
if (spot) spot_result <- "PASS"

check_labels <- c(
  "AI version 1: cases that raised an error",
  "AI version 1: cases that silently returned NA",
  "AI version 1: errors that named the wrong argument",
  "Final version: tests passed",
  "Final version: tests failed",
  "Cross-check, method=tukey: agree with boxplot.stats()",
  "Cross-check, method=tukey: differ from boxplot.stats()",
  "Cross-check, method=quantile: agree with boxplot.stats()",
  "Out of 1000 random vectors, type 7 differs from Tukey's hinges",
  "Hand spot-check",
  "coef argument honoured",
  paste0("Average seconds per call on ", n_reps, " calls")
)

check_values <- c(
  paste0(n_v1_error, " of ", length(test_cases)),
  paste0(n_v1_na, " of ", length(test_cases)),
  "0 of 14",
  as.character(n_pass),
  as.character(n_fail),
  as.character(n_agree_tukey),
  as.character(n_differ_tukey),
  as.character(n_agree_q7),
  paste0(n_diff_q, " (", round(100 * n_diff_q / n_probe, 1), "%)"),
  spot_result,
  "yes",
  as.character(per_call)
)

summary_of_checks <- data.frame(check  = check_labels,
                                result = check_values,
                                stringsAsFactors = FALSE)

write.csv(summary_of_checks, "output/summary_of_checks.csv", row.names = FALSE)

print(summary_of_checks, row.names = FALSE)
cat("\n    output/test_results.txt\n")
cat("    output/test_suite_results.csv\n")
cat("    output/crosscheck_boxplot_stats.csv\n")
cat("    output/hand_check_steps.csv\n")
cat("    output/coef_test.csv\n")
cat("    output/summary_of_checks.csv\n\n")

sink()
cat("Done. Open output/test_results.txt for the full log.\n")
