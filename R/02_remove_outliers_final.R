# =====================================================================
#  remove_outliers()  -  THE FINAL, HUMAN-REFINED FUNCTION
#  BDA400 / Data Science Tools and Techniques - Assignment 3
#  Prompting R Functions with AI
#
#  This is the finished function. It started as AI-generated code
#  (version 1, kept unchanged in R/03_ai_version_v1.R) and was
#  corrected by hand after the test harness in R/04_test_and_verify.R
#  exposed three real defects. Every change is listed in the
#  CHANGES FROM THE AI VERSION block at the bottom of this file and is
#  justified in the report.
#
#  TASK: remove outliers from a numeric vector using Tukey's
#        1.5 x IQR rule.
# =====================================================================


#' Remove outliers from a numeric vector using Tukey's IQR rule
#'
#' A value is flagged as an outlier when it falls outside the fences
#'
#'     lower fence = Q1 - coef * IQR
#'     upper fence = Q3 + coef * IQR      where IQR = Q3 - Q1
#'
#' @details
#' R does not agree with itself on how to calculate a quartile, and the
#' choice genuinely changes the answer. This function therefore offers
#' three methods:
#'
#' \describe{
#'   \item{"tukey"}{Tukey's hinges, via [stats::fivenum()]. This is the
#'     default because it is the method R's own [grDevices::boxplot.stats()]
#'     uses, so this function agrees with R's built-in boxplot exactly.}
#'   \item{"quantile"}{[stats::quantile()] with the R default
#'     `type = 7`. This is what most R tutorials use, and it is also what
#'     Excel's QUARTILE.INC and QUARTILE calculate, so it is the method to
#'     choose when checking the result in a spreadsheet.}
#'   \item{"type1"}{[stats::quantile()] with `type = 1`, the inverse of
#'     the empirical distribution function. Included because it is what
#'     some statistical textbooks teach, so a reader can reproduce a
#'     published quartile.}
#' }
#'
#' On 1000 random test vectors, "tukey" and "quantile" produced different
#' quartiles on 521 of them, so the method argument is not cosmetic.
#'
#' @param x numeric vector to clean
#' @param coef positive multiplier applied to the IQR. 1.5 is the
#'   standard Tukey value; a larger number flags fewer points.
#' @param na.rm if `TRUE` (the default) missing values are removed before
#'   the quartiles are calculated. If `FALSE` they are an error.
#' @param method which quartile estimator to use - see Details.
#' @param return `"clean"` to get just the vector with the outliers
#'   removed, `"outliers"` to get just the outlier values, or `"full"`
#'   to get a list containing the cleaned vector, the outliers, the
#'   quartiles and the fences.
#'
#' @return a numeric vector, or a named list, depending on `return`.
#'
#' @author Paula Eriya - BDA400 Data Science Tools and Techniques
#' @seealso [grDevices::boxplot.stats()], [stats::fivenum()],
#'   [stats::quantile()]
#' @export
remove_outliers <- function(x,
                            coef   = 1.5,
                            na.rm  = TRUE,
                            method = c("tukey", "quantile", "type1"),
                            return = c("clean", "outliers", "full")) {

  # ---- 1. ARGUMENT VALIDATION ----------------------------------------
  # CHANGE 1a. The AI version validated nothing, so passing text crashed
  # deep inside the arithmetic with a message about a "binary operator"
  # that never mentioned the 'x' argument.

  if (!is.numeric(x)) {
    stop("'x' must be a numeric vector, not ", class(x), ".",
         call. = FALSE)
  }
  if (length(coef) != 1L || !is.numeric(coef) ||
      !is.finite(coef) || coef <= 0) {
    stop("'coef' must be a single positive number.", call. = FALSE)
  }
  method <- match.arg(method)
  return <- match.arg(return)

  # ---- 2. HANDLE MISSING VALUES --------------------------------------
  # CHANGE 1b. This is the important one. The AI version passed
  # na.rm = TRUE to quantile() but then compared the ORIGINAL x, which
  # still contained the NAs, and handed those NAs straight back inside
  # the "cleaned" vector without any warning.

  n_missing <- sum(is.na(x))
  if (na.rm) {
    x <- x[!is.na(x)]
  } else if (n_missing > 0L) {
    stop("'x' contains ", n_missing, " missing value(s). ",
         "Use na.rm = TRUE to remove them.", call. = FALSE)
  }

  if (length(x) == 0L) {
    stop("No usable values left in 'x' (", n_missing,
         " missing value(s)). Nothing to analyse.", call. = FALSE)
  }

  # ---- 3. CALCULATE THE QUARTILES ------------------------------------
  # CHANGE 1c. The AI version hard-coded quantile(type = 7), which meant
  # its answer could never be made to agree with R's boxplot.stats(),
  # because boxplot.stats() uses Tukey's hinges instead.

  if (method == "tukey") {
    hinges <- stats::fivenum(x)     # min, Q1, median, Q3, max
    q1 <- hinges[2]
    q3 <- hinges[4]

  } else if (method == "quantile") {
    q <- stats::quantile(x, probs = c(0.25, 0.75), names = FALSE,
                         type = 7)
    q1 <- q[1]
    q3 <- q[2]

  } else {                          # "type1"
    q <- stats::quantile(x, probs = c(0.25, 0.75), names = FALSE,
                         type = 1)
    q1 <- q[1]
    q3 <- q[2]
  }

  iqr <- q3 - q1

  # a non-finite IQR means the vector still holds Inf, -Inf or NaN
  if (!is.finite(iqr)) {
    stop("The IQR is not a finite number, so the fences cannot be ",
         "calculated. 'x' probably contains Inf, -Inf or NaN. ",
         "Remove those values first.", call. = FALSE)
  }

  # ---- 4. THE FENCES --------------------------------------------------

  lower_fence <- q1 - coef * iqr
  upper_fence <- q3 + coef * iqr

  # ---- 5. SPLIT -------------------------------------------------------

  is_outlier <- (x < lower_fence) | (x > upper_fence)
  outliers   <- x[is_outlier]
  clean      <- x[!is_outlier]

  # ---- 6. RETURN -------------------------------------------------------

  if (return == "clean") {
    return(clean)
  }

  if (return == "outliers") {
    return(outliers)
  }

  # return == "full"
  list(
    clean       = clean,
    outliers    = outliers,
    lower_fence = lower_fence,
    upper_fence = upper_fence,
    q1          = q1,
    q3          = q3,
    iqr         = iqr,
    coef        = coef,
    method      = method,
    n_in        = length(x),
    n_outliers  = length(outliers),
    n_missing   = n_missing
  )
}


# =====================================================================
#  CHANGES FROM THE AI VERSION
#
#  Three defects were found by RUNNING the AI code, not by reading it.
#  Each fix is marked CHANGE 1a / 1b / 1c in the code above.
#
#  ------------------------------------------------------------------
#  1a  ARGUMENT VALIDATION  (found by: remove_outliers_v1(c("a","b","c")))
#      AI  : crashed with "non-numeric argument to binary operator", a
#            message raised deep inside the arithmetic that never says
#            which argument was wrong.
#      NOW : checks is.numeric(x) and stop()s with
#            "'x' must be a numeric vector, not character."
#            'coef' is also checked to be a single positive number.
#
#  1b  MISSING VALUES  (found by: remove_outliers_v1(c(10,15,NA,999,20,25,NA)))
#      AI  : silently returned 10, 15, NA, 20, 25, NA - the missing
#            values were passed straight back inside the "cleaned"
#            vector, and nothing warned about it. On c(NA,NA,NA) it
#            crashed with "missing value where TRUE/FALSE needed".
#            The same mistake gave a silent wrong answer in one case and
#            a crash in the other; the silent one is the dangerous one.
#      NOW : NA is removed up front, the number removed is reported in
#            n_missing, and na.rm = FALSE turns missing values into a
#            clear error instead of a surprise.
#
#  1c  CHOICE OF QUARTILE METHOD  (found by: comparing with boxplot.stats())
#      AI  : hard-coded quantile(x, 0.25), i.e. type 7, with no way to
#            change it and no way to make it agree with R's own
#            boxplot.stats(), which uses Tukey's hinges (fivenum()).
#            Measured on 1000 random vectors, type 7 and Tukey's hinges
#            disagree on 521 of them.
#      NOW : method = "tukey" (default, matches boxplot.stats()),
#            "quantile" (type 7, matches Excel's QUARTILE.INC) or
#            "type1". The default is "tukey" precisely so the function
#            reproduces R's built-in boxplot.
#
#  ------------------------------------------------------------------
#  ALSO ADDED, because the AI version had no way to be checked:
#    - return = "full", so the quartiles, the IQR and the fences come
#      back with the answer and the arithmetic can be inspected.
#    - return = "outliers", so the removed values can be reported
#      separately instead of only being implied by a difference in
#      length.
#    - roxygen documentation above, plus the notes in this block.
# =====================================================================
