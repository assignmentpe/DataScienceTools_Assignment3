# Assignment 3 - Prompting R Functions with AI

**Module:** BDA400 / Data Science Tools and Techniques
**Student:** Paula Eriya
**Weight:** 5% of the module grade  |  **Due:** Session 5

An R function, `remove_outliers()`, was written with ChatGPT through a sequence of
prompts, then debugged and verified by hand. This folder holds the prompts, both
versions of the function, the test evidence and the written report.

> **AI Assistance Declaration.** ChatGPT was used to write and revise the R
> function. All final calculations, all verification and all conclusions are my
> own. No real or personal data was sent to any AI tool; every dataset here is
> synthetic.

---

## What to submit

| File | What it is |
|---|---|
| `Paula_Eriya_CA_BDA400_A03.pdf` | **The submission.** The full report, with the declaration on page 1 |
| `Paula_Eriya_CA_BDA400_A03.docx` | The same report in Word, if an editable copy is wanted |
| `Eriya_Reflection.docx` | The reflection on its own, as named in the brief |
| `Eriya_AI_RFunction_Assignment.R` | The self-contained R script: AI version 1, the final version, and the test suite |

The PDF and the reflection are the two documents the brief asks for by name. The
`.R` file is the code the report quotes, and it is the same code the tests ran.

---

## Folder layout

```
Assignment3/
|-- Paula_Eriya_CA_BDA400_A03.pdf    <- the report, submit this
|-- Paula_Eriya_CA_BDA400_A03.docx
|-- Eriya_Reflection.docx
|-- Eriya_AI_RFunction_Assignment.R  <- version 1, the final version, and the tests
|-- Assignment3.Rproj
|-- R/
|   |-- 01_synthetic_data.R         <- every dataset, all made with set.seed()
|   |-- 02_remove_outliers_final.R  <- the final function, as a standalone file
|   |-- 03_ai_version_v1.R          <- version 1 exactly as ChatGPT wrote it
|   `-- 04_test_and_verify.R        <- the 14-case test suite and the cross-checks
|-- output/
|   |-- test_results.txt            <- the full console log, saved
|   |-- test_suite_results.csv      <- pass/fail, case by case
|   |-- crosscheck_boxplot_stats.csv <- my function against R's own
|   |-- hand_check_steps.csv        <- the arithmetic, worked out longhand
|   |-- coef_test.csv               <- the 1.5 multiplier swept from 2.0 to 1.0
|   |-- summary_of_checks.csv       <- the headline numbers
|   `-- revenue_values.txt          <- the values the spreadsheet uses
|-- crosscheck/
|   `-- PAULAERIYA_tukey_spreadsheet_check.xlsx   <- the independent hand check
|-- appendix/
|   |-- Eriya_PROMPTS_to_paste_into_ChatGPT.md    <- the 8 prompts, ready to paste
|   `-- Eriya_AI_Prompts_and_Responses.docx       <- prompts and replies side by side
`-- screenshots/                    <- RStudio screenshots for the report
```

---

## How to run it

**The quickest way** - open the project and run one file:

1. Open RStudio.
2. `File > Open Project...` and choose `Assignment3/Assignment3.Rproj`.
   Opening the *project* sets the working folder to `Assignment3/`, which is what
   makes the relative paths work.
3. Open `Eriya_AI_RFunction_Assignment.R` and click **Source**.

That single file is self-contained. It defines version 1, defines the final
version, and runs the whole test suite. It rewrites everything in `output/`.

**Or run the `R/` files in order**, which is how the report's screenshots were
taken:

1. `R/01_synthetic_data.R` - makes the datasets.
2. `R/02_remove_outliers_final.R` - the final function.
3. `R/03_ai_version_v1.R` - version 1, kept unaltered so the bugs can be shown.
4. `R/04_test_and_verify.R` - the tests, the cross-checks and the log.

No packages are needed. Everything uses base R only, so there is nothing to
install and `sessionInfo()` shows a clean `R 4.6.1`.

---

## The function

```r
remove_outliers(x, coef = 1.5, method = "tukey", na.rm = TRUE, return = "clean")
```

| Argument | Meaning | Default |
|---|---|---|
| `x` | the numeric vector | required |
| `coef` | the IQR multiplier; 1.5 is Tukey's rule | `1.5` |
| `method` | how the quartiles are calculated: `"tukey"`, `"quantile"` or `"type1"` | `"tukey"` |
| `na.rm` | drop `NA` before working | `TRUE` |
| `return` | `"clean"`, `"outliers"` or `"full"` | `"clean"` |

A value is an outlier when it falls outside

```
lower fence = Q1 - coef * IQR        upper fence = Q3 + coef * IQR
```

### Why `method = "tukey"` is the default

R's own `boxplot.stats()` does **not** use `quantile()`. It uses `fivenum()`,
which returns Tukey's hinges. The two disagree: on a random sample of 1000
vectors, the type 7 quartiles from `quantile()` put a different set of values
outside the fences from Tukey's hinges in **521 cases, 52.1% of the time**.

Since Tukey's hinges reproduce `boxplot.stats()` exactly - 11 agree, 0 differ
across the test suite - `"tukey"` is the default. `"quantile"` is kept so the two
can be compared, and because it is what Excel's `QUARTILE.INC` does, which is
what the spreadsheet cross-check uses.

---

## What testing found

| Check | Result |
|---|---|
| Version 1 raises an error | 2 of 14 cases |
| Version 1 silently returns `NA` | 1 of 14 cases |
| Final version, tests passed | **14 of 14** |
| Agreement with `boxplot.stats()` | **11 agree, 0 differ**, 3 not applicable |
| Hand-worked example | matches |
| Speed, 10,002 values | about 0.0009 s per call |

The three defects in version 1:

1. **No `NA` handling.** It passed `na.rm = TRUE` to `quantile()`, so the fences
   were right, but then compared the *original* vector, which still held the
   `NA`s. A comparison with `NA` returns `NA`, so the function handed the missing
   values back inside a result it called clean, with no warning.
2. **All-`NA` vector crashes.** `c(NA, NA, NA)` gives
   `missing value where TRUE/FALSE needed`.
3. **Text input gives a confusing error** rather than a clear one.

Defect 1 is the important one, because the function does not fail. It returns a
wrong answer quietly.

Three independent checks were used, in the order the brief asks for:

1. **Primary calculation by hand** - `crosscheck/PAULAERIYA_tukey_spreadsheet_check.xlsx`
   rebuilds the whole calculation in a spreadsheet with live formulas, from the
   values in `output/revenue_values.txt`. Both verdicts read MATCH.
2. **Independent cross-check** - against R's built-in `boxplot.stats()`, which
   was never used to write the function.
3. **Self spot-check** - one example worked out longhand, plus the edge cases
   that break version 1.

---

## Before submitting

- [ ] Paste ChatGPT's replies into `appendix/Eriya_AI_Prompts_and_Responses.docx`.
      They cannot be written for you, and the brief requires the actual conversation.
- [ ] Fill in the **ChatGPT model version** and the **dates** on the declaration
      page. Three `FILL IN` markers are left in the report.
- [ ] Fill in the **real RStudio error message** for prompt P4, in
      `appendix/Eriya_PROMPTS_to_paste_into_ChatGPT.md`.
- [ ] Put the RStudio screenshots in `screenshots/`.
