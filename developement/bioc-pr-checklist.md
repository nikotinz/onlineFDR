########################################################################
Bioconductor PR checklist (keep on dev branch)
########################################################################

- Versioning: `DESCRIPTION` uses devel version (e.g., 2.19.x), update `Date`, add NEWS entry matching the version.
- Docs: regenerate with roxygen2 (`devtools::document()`), commit `NAMESPACE`, `man/`, and `inst/CITATION`.
- Site: rebuild pkgdown and commit updated `docs/`.

```r
pkgdown::build_site_github_pages()
```

# CRAN deps
install.packages(c("roxygen2", "pkgdown", "progress", "RcppProgress"), repos = "https://cloud.r-project.org")

# Ensure roxygen2 is 7.3.3
`packageVersion("roxygen2")`  # should show ‘7.3.3’

# Bioconductor dep
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("BiocCheck")  # use Bioc devel if you’re targeting Bioc devel

# Optional: install covr if you run coverage locally
install.packages("covr", repos = "https://cloud.r-project.org")

```r
cov <- covr::package_coverage()   # runs tests, computes coverage
covr::report(cov)      
covr::percent_coverage(cov) # quick summary
```

- Build ignores: ensure `developement/`, Lassie assets, and other dev artifacts are excluded.
  Check `.Rbuildignore`
- CI: run `R CMD check` + `BiocCheck::BiocCheckGitClone()` locally; ensure workflows are green.

```r
devtools::check()
BiocCheck::BiocCheckGitClone()
devtools::build()
```

```terminal
R CMD check onlineFDR_2.19.1.tar.gz
R CMD check --as-cran onlineFDR_2.19.1.tar.gz
```

- Branch hygiene: push only essentials to `master`: `DESCRIPTION`, `inst/NEWS`, package code (`R/`, `src/`), tests (`tests/`), roxygen outputs (`NAMESPACE`, `man/`, `inst/CITATION`), pkgdown `docs/`, vignettes, and other package data under `inst/`. Keep dev scripts/data in `developement/` or on `dev` only.

Git commands to push essentials to `master`

```bash
# 1) Start from dev and make sure everything is committed
git status

# 2) Switch to master and update it
git checkout master
git pull origin master

# 3) Stage only the essential files
# Bring over files without dev extras
git checkout dev -- README.md README.Rmd NAMESPACE DESCRIPTION .Rbuildignore .gitignore _pkgdown.yml vignettes tests src R pkgdown man inst docs .github .vscode
git add README.md README.Rmd NAMESPACE DESCRIPTION .Rbuildignore .gitignore _pkgdown.yml vignettes tests src R pkgdown man inst docs .github .vscode
git commit -m "Prep for Bioconductor submission"

# 4) Push master
git push origin master
```
