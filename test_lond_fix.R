# Test the LOND fix
source("R/setBound.R")
source("R/checkPval.R")
source("R/checkdf.R")

# Load the LOND function - first need to check if we need other dependencies
if (!exists("lond_faster")) {
  # Simple test without the C++ function
  alpha <- 0.04
  bound <- setBound("LOND", alpha = alpha, 20)
  
  cat("Testing setBound with LOND tolerance fix:\n")
  cat("alpha:", alpha, "\n")
  cat("sum(bound):", sum(bound), "\n")
  cat("difference:", sum(bound) - alpha, "\n")
  cat("tolerance:", .Machine$double.eps * 20, "\n")
  cat("passes validation:", sum(bound) <= alpha + .Machine$double.eps * 20, "\n")
} else {
  source("R/LOND.R")
  cat("Full LOND function test would go here\n")
}
