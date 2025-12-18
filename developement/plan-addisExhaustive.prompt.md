---
title: "ADDIS_Exhaustive integration plan"
pkgdown: false
---

ADDIS_Exhaustive integration plan

1. Inspect Lassie exhaustive ADDIS code
	- Open `Lassie/Exhaustive-ADDIS-procedures-main` and identify the core R functions implementing the exhaustive ADDIS procedure (excluding scripts that are only simulations, plotting, or CLI wrappers).
	- Determine the natural "entry point" function (inputs/outputs) that corresponds to a single stream of p-values, and note any required hyperparameters.
	- Note any dependencies on global variables, options, or sourced files that need to be encapsulated or inlined.

2. Design `ADDIS_Exhaustive()` interface
	- Start from the current `ADDIS()` function in `R/ADDIS.R` and mirror its public signature as closely as reasonable (e.g., `d`, `alpha`, possibly `tau`, `lambda`, `version`, `display_progress`, etc.), but only keep parameters that are actually meaningful for the exhaustive algorithm.
	- Decide whether `ADDIS_Exhaustive()` supports both vector and data.frame inputs (like `ADDIS()`); if so, reuse `checkPval()` and `checkdf()` in the same way.
	- Define the return value to match the standard onlineFDR pattern: a data.frame with at least `pval`, the per-time alpha/threshold sequence (e.g., `alphai`), and `R` (rejection indicator), plus any other fields that are natural for this method.

3. Create `R/ADDIS_Exhaustive.R`
	- Create a new R file `R/ADDIS_Exhaustive.R` in the package.
	- Implement the high-level wrapper `ADDIS_Exhaustive()` that:
	  - Validates `d` using `checkPval()` (for vectors) or `checkdf()` (for data.frames) following the style of `ADDIS()`.
	  - Extracts/normalizes the p-value vector and any IDs/order information.
	  - Sets up algorithm parameters with defaults consistent with Lassie’s exhaustive ADDIS (document any differences in the roxygen comments).
	  - Calls an internal R helper (e.g., `.addis_exhaustive_core()`) that is a direct adaptation of the Lassie code.
	  - Wraps the core’s output into an `onlineFDR`-style data.frame and returns it.

4. Copy and adapt Lassie exhaustive ADDIS core
	- Within `R/ADDIS_Exhaustive.R`, copy the minimal set of functions from `Lassie/Exhaustive-ADDIS-procedures-main` needed for the exhaustive ADDIS logic (e.g., allocation of alpha-wealth, updating rules, decision rules).
	- Keep function bodies as close as possible to the original to preserve correctness, but:
	  - Comment out (do not delete) any plotting calls (e.g., `plot()`, `ggplot2`, `pdf()`, `dev.off()`).
	  - Keep (so far) any printing/logging (`print()`, `cat()`, `message()`).
	  - Comment out any file I/O (`write.csv`, `read.csv`, `saveRDS`, `sink`, etc.).
	- Ensure the copied core functions are pure in the sense of not relying on external sourced files; inline any small utility functions they depend on, or reimplement them locally if necessary.

5. Align naming and style with onlineFDR
	- Rename internal functions to follow existing naming conventions (e.g., prefix with `.addis_exhaustive_`) if that improves clarity, but avoid deep refactors that risk introducing bugs.
	- Use argument names consistent with `ADDIS()` and other package functions (`alpha`, `tau`, `lambda`, etc.) where applicable.
	- Follow the package’s error message patterns (e.g., "All p-values must be between 0 and 1.", "The sum of the elements of betai must not be greater than alpha.") for any new validations.

6. Handle vector vs dataframe inputs
	- If `d` is a numeric vector:
	  - Validate via `checkPval(d)`.
	  - Treat indices `1:N` as the testing order.
	- If `d` is a data.frame:
	  - Validate via `checkdf(d)` and ensure required columns (`pval`, and optionally `id`/`date` for ordering) are present.
	  - Respect any ordering semantics already used by `ADDIS()` for batch or time-ordered data.
	- Make sure the output data.frame preserves useful identifiers (e.g., `id` or original row order) consistent with other procedures.

7. Ensure numerical behavior and edge cases
	- Consider how the exhaustive ADDIS code treats zero, one, and NA p-values; align with `checkPval()` semantics.
	- If the method uses bound sequences or cumulative sums that should not exceed `alpha`, follow the same tolerance strategy used elsewhere (e.g., `alpha + .Machine$double.eps * length(sequence)`).
	- Verify behavior on small `N` (e.g., 1–5 hypotheses) and on all-rejected or no-rejection scenarios.

8. Document `ADDIS_Exhaustive()`
	- Add roxygen comments above `ADDIS_Exhaustive()` describing:
	  - Purpose and relation to `ADDIS()`.
	  - Arguments and defaults.
	  - Return value structure.
	  - References to the Lassie exhaustive ADDIS method / paper.
	- Run `devtools::document()` (or equivalent) to generate the `.Rd` file in `man/`.

9. Add tests for `ADDIS_Exhaustive()`
	- Create `tests/testthat/test_ADDIS_Exhaustive.R` with:
	  - A smoke test on a small numeric vector of p-values, checking that the function returns a data.frame with columns `pval`, `alphai` (or the appropriate threshold column name), and `R`, and that `R` is 0/1.
	  - Similar test for a small data.frame input with a `pval` column (and optional `id`), ensuring that output aligns with input ordering.
	  - One or two basic correctness checks using simple p-value patterns where expected rejections are easy to reason about (e.g., very small vs very large p-values).
	  - Validation tests to ensure that invalid inputs (e.g., p-values outside [0,1], missing `pval` column) fail with informative errors, mirroring `ADDIS()` behavior.
	- If feasible, add a regression-style test comparing the output of `ADDIS_Exhaustive()` on a fixed input to a precomputed reference result generated from the original Lassie code.

10. Run checks and iterate
	- Run the package tests:

	  devtools::test()

	- Run a full R CMD check locally (optionally skipping vignettes during iteration):

	  Rscript -e "rcmdcheck::rcmdcheck(args = c('--no-manual'), error_on = 'error')"

	- Fix any test or check failures, keeping changes minimal and aligned with existing patterns.
	- Once stable, consider adding a short example or mention of `ADDIS_Exhaustive()` in a vignette (e.g., `advanced-usage.Rmd`), using small examples that run quickly.
