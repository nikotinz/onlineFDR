# Diagnostic script for the specific macOS precision issue
# This reproduces the exact vignette scenario

cat("=== Diagnostic for macOS precision issue ===\n")
cat("Platform:", R.version$platform, "\n")
cat("R version:", R.version$version.string, "\n\n")

# Exact values from the vignette
alpha <- 0.04
N <- 20

cat("alpha =", alpha, "\n")
cat("N =", N, "\n")
cat("alpha/N =", alpha/N, "\n\n")

# Test setBound function (if available)
if (exists("setBound")) {
  source("R/setBound.R")
  bound <- setBound("LOND", alpha = alpha, N)
} else {
  # Manual calculation
  bound <- rep(alpha/N, N)
}

sum_bound <- sum(bound)
diff <- sum_bound - alpha
eps <- .Machine$double.eps

cat("=== Results ===\n")
cat("sum(bound) =", format(sum_bound, digits=20), "\n")
cat("alpha =", format(alpha, digits=20), "\n")
cat("difference =", format(diff, digits=20), "\n")
cat("abs(difference) =", format(abs(diff), digits=20), "\n")
cat("Machine epsilon =", format(eps, digits=20), "\n")
cat("eps * N =", format(eps * N, digits=20), "\n\n")

cat("=== Validation Tests ===\n")
cat("sum(bound) > alpha (strict):", sum_bound > alpha, "\n")
cat("abs(diff) <= eps * N:", abs(diff) <= eps * N, "\n")
cat("abs(diff) <= 10 * eps * N:", abs(diff) <= 10 * eps * N, "\n")
cat("abs(diff) <= 100 * eps * N:", abs(diff) <= 100 * eps * N, "\n")

if (sum_bound > alpha) {
  cat("\n*** PRECISION ISSUE DETECTED ***\n")
  cat("This would cause the LOND validation to fail.\n")
  cat("Recommended fix: Add tolerance to validation check.\n")
} else {
  cat("\nNo precision issue detected on this platform.\n")
}
