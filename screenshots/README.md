# Screenshots

RStudio screenshots that back up the report. The report references these; the
files themselves are added here as they are taken.

Name them in the order the report mentions them, and use the same numbering
style as the file names below.

| # | File name | What it shows |
|---|---|---|
| 01 | `01_rstudio_version.png` | RStudio open, with the R version visible in the console |
| 02 | `02_project_opened.png` | `Assignment3.Rproj` open, proving the working folder is correct |
| 03 | `03_running_tests.png` | `Eriya_AI_RFunction_Assignment.R` sourced, tests running |
| 04 | `04_version1_failures.png` | Version 1 raising `missing value where TRUE/FALSE needed` |
| 05 | `05_version1_silent_na.png` | Version 1 returning `NA` values with no warning |
| 06 | `06_final_all_pass.png` | The final version, 14 of 14 tests passed |
| 07 | `07_boxplot_stats_crosscheck.png` | My function beside R's own `boxplot.stats()` |
| 08 | `08_spreadsheet_crosscheck.png` | The spreadsheet cross-check showing MATCH |

## How to take one

1. Set the window up so the thing you want to prove is visible, not just the
   code. A screenshot that only shows code proves nothing.
2. RStudio: `Session > Restart R`, run the file, then
   `Screenshot >` nothing in particular - use Windows `Win + Shift + S` to
   snip the area.
3. Paste into Paint or Paint 3D if you need to crop.
4. Save into this folder with the file name from the table above.
5. Push: `git add screenshots` then `git commit` then `git push`.
