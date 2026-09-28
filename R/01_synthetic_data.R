# =====================================================================
#  SYNTHETIC DATA FOR ASSIGNMENT 3
#  BDA400 / Data Science Tools and Techniques - Assignment 3
#  Prompting R Functions with AI
#
#  AI Assistance Declaration:
#  I used ChatGPT for generating and revising the remove_outliers() R
#  function. Prompts used: see appendix/Eriya_PROMPTS_to_paste_into_
#  ChatGPT.md. I verified outputs using (a) a manual Tukey calculation
#  built in a spreadsheet, (b) an independent cross-check against R's
#  built-in boxplot.stats() and fivenum(), and (c) a self spot-check on
#  a hand-worked example plus a 12-case edge-case battery. All final
#  calculations are done by myself. I am responsible for the accuracy
#  and originality of this work.
#
#  ---------------------------------------------------------------
#  PRIVACY (AI Usage Rule 9)
#  Every vector below is SYNTHETIC - invented for this assignment.
#  Nothing here is real, personal, confidential or college data.
#  The random vectors use a fixed seed so the results are identical
#  on every computer and can be checked by the marker.
#  ---------------------------------------------------------------
# =====================================================================

# --- a small hand-checkable vector (the example named in the brief) ---
synthetic_basic <- c(10, 15, 999, 20, 25)

# --- a vector with NO outliers, to prove the function is not too eager -
synthetic_clean <- c(12, 15, 18, 22, 25)

# --- one extreme value on the HIGH side -------------------------------
synthetic_high_outlier <- c(10, 12, 14, 16, 18, 20, 999)

# --- one extreme value on the LOW side --------------------------------
synthetic_low_outlier <- c(-500, 10, 12, 14, 16, 18, 20)

# --- outliers on BOTH sides ------------------------------------------
synthetic_both_sides <- c(-1000, 10, 12, 14, 16, 18, 1000)

# --- missing values, which is the first real bug the AI code has ------
synthetic_with_na <- c(10, 15, NA, 999, 20, 25, NA)

# --- every value identical: IQR is zero, so the fences collapse -------
synthetic_all_same <- rep(7, 8)

# --- only two observations: too short to be meaningful ----------------
synthetic_too_short <- c(3, 9)

# --- a single observation --------------------------------------------
synthetic_single <- 42

# --- nothing at all ----------------------------------------------------
synthetic_empty <- numeric(0)

# --- only missing values ---------------------------------------------
# NB: c(NA, NA, NA) is a LOGICAL vector in R, not a numeric one, so it
# would be rejected by is.numeric() before it ever reached the NA logic.
# as.numeric() makes it a genuine numeric vector of missing values, which
# is the edge case actually worth testing.
synthetic_all_na <- as.numeric(c(NA, NA, NA))

# --- text where numbers were expected (should give a clear error) -----
synthetic_text <- c("a", "b", "c")

# --- a realistic "revenue per order" style synthetic vector -----------
# log-normal shape, seed fixed so the marker gets identical numbers
set.seed(42)
synthetic_revenue <- round(stats::rlnorm(200, meanlog = 3.6, sdlog = 0.5), 2)

# --- a larger vector used only for the speed test ---------------------
# The base values are drawn from a UNIFORM distribution on purpose.
# A normal distribution has real tails, so the 1.5 x IQR rule would flag
# genuine tail observations as well as the two values added below, and
# the count would be hard to predict. A uniform base has no tails, so
# the only outliers in this vector are the two added on purpose and the
# expected answer is exactly 2.
set.seed(7)
synthetic_large <- c(stats::runif(10000, min = 90, max = 110), 9000, -9000)

# --- a deliberately awkward one: 5 values, ties, and a decimal --------
synthetic_awkward <- c(1.5, 1.5, 2.0, 2.0, 40.0)
