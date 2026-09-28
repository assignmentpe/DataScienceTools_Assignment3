# =====================================================================
#  THE AI-GENERATED FUNCTION - VERSION 1
#  BDA400 / Data Science Tools and Techniques - Assignment 3
#
#  WHAT THIS FILE IS
#  This is the function exactly as ChatGPT returned it for the seed
#  prompt "Write an R function that removes outliers from a numeric
#  vector using the 1.5 times IQR rule."
#
#  It is kept in the repository, unaltered, for two reasons:
#    1. the brief requires the AI-generated function to be submitted
#    2. the test harness in 04_test_and_verify.R actually RUNS it, so
#       the three defects listed below are demonstrated, not asserted
#
#  DO NOT "FIX" THIS FILE. The bugs are the evidence.
# =====================================================================


# --- the function as ChatGPT first returned it -------------------------
remove_outliers_v1 <- function(x, iqr_multiplier = 1.5) {

  Q1 <- quantile(x, 0.25, na.rm = TRUE)
  Q3 <- quantile(x, 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1

  lower_bound <- Q1 - iqr_multiplier * IQR
  upper_bound <- Q3 + iqr_multiplier * IQR

  if (any(x < lower_bound) || any(x > upper_bound)) {
    x_clean <- x[x >= lower_bound & x <= upper_bound]
    return(x_clean)
  }

  return(x)
}


# =====================================================================
#  THE THREE DEFECTS, AND HOW THEY WERE FOUND
#  (each one was found by running the code, not by reading it)
# =====================================================================
#
#  DEFECT 1 - no argument validation
#  FOUND BY: remove_outliers_v1(c("a", "b", "c"))
#  RESULT:   it does fail, but with the message
#            "non-numeric argument to binary operator"
#            which is raised deep inside the arithmetic and never mentions
#            the 'x' argument or tells the caller what they did wrong.
#  WHY AI:   the model produced a happy-path answer. It wrote the maths
#            correctly and never considered what happens when a user
#            passes the wrong type. This is the classic AI failure mode:
#            plausible code for the example in the prompt, no defensive
#            programming around it.
#
#  DEFECT 2 - no handling of NA.  THE MOST DANGEROUS ONE.
#  FOUND BY: remove_outliers_v1(c(10, 15, NA, 999, 20, 25, NA))
#  RESULT:   it did NOT report an error. It returned
#                10, 15, NA, 20, 25, NA
#            The 999 was correctly removed, but both NA values were
#            handed straight back in the "cleaned" vector.
#  WHY AI:   a genuinely subtle bug, and the most interesting one. The
#            function passes na.rm = TRUE to quantile(), so the fences are
#            calculated correctly from the 5 real numbers. The bug is in
#            the SECOND step. `any(x < lower_bound)` is evaluated on the
#            ORIGINAL x, which still contains NA. In R a comparison with
#            NA returns NA, so `any()` returns TRUE (because the 999 is
#            genuinely an outlier), and the subsetting line
#            `x[x >= lower_bound & x <= upper_bound]` produces NA in the
#            TRUE/FALSE vector, which R uses as an index. The result is a
#            "clean" vector that still contains the missing values.
#            A related input - c(NA, NA, NA) - DOES crash, with
#            "missing value where TRUE/FALSE needed", because there
#            every comparison is NA and `if (NA)` is an error.
#            The lesson: the same missing-value mistake produced a
#            silent wrong answer in one case and a crash in the other.
#            The silent one is far worse, because nothing warns you.
#
#  DEFECT 3 - the multiplier is hard-coded in spirit and the quartile
#             method cannot be chosen
#  FOUND BY: comparing the result with boxplot.stats()
#  RESULT:   for some vectors the two disagree about which values are
#            outliers, e.g. c(1.5, 1.5, 2.0, 2.0, 40.0)
#  WHY AI:   the model reached for quantile() because that is the
#            obvious, idiomatic R choice, and did not know that R's own
#            boxplot.stats() does NOT use quantile() - it uses
#            median(x[x <= quantile(x, 1/4)]). This is a knowledge gap,
#            not a coding slip, and it is exactly the kind of thing a
#            function is supposed to let the user control.
