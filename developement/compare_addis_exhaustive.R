# TODO
# * Think about longtime computations to test how fast it's going to work?
# * Do we need "display_progress parameter"?
# * Do we need "Date format"?

# Source original Lassie implementation
lassie_path <- "Lassie/Exhaustive-ADDIS-procedures-main/Exhaustive_Procedures.R"
if (!file.exists(lassie_path)) {
  stop("Cannot find ", lassie_path, ". Make sure the Lassie folder is present.")
}

source(lassie_path)


devtools::load_all(".")


set.seed(123)
p <- runif(50)
alpha  <- 0.05
n      <- length(p)
tau    <- 0.5
lambda <- 0.25

# Default gamma sequence as in ADDIS / ADDIS_exhaustive
gamma_full  <- 0.4374901658 / (seq_len(n + 1)^(1.6))


#^ Lassie/E_ADDIS_Spending expects a gamma vector of length n (the original
#^ code warns if lengths mismatch). Pass the first n elements to the original
#^ function to avoid the "mismatching length" warning while keeping the
#^ package default (length n+1) for our implementation.
#^ gamma_for_lassie <- gamma_full[1:n]

# Original E_ADDIS_Spending function
alpha_ind_orig <- E_ADDIS_Spending(alpha, 
                                    gamma_full, 
                                    tau, 
                                    lambda, 
                                    p, 
                                    n)


# OnlineFDR function
res <- ADDIS_exhaustive(d = p, alpha = alpha, tau = tau, lambda = lambda,
                        gamma = gamma_full)
alpha_ind_OnlineFDR <- res$alphai
alpha_ind_orig == alpha_ind_OnlineFDR

###############################################################################
# Extra tests
###############################################################################
test.pval <- c(1e-07, 3e-04, 0.1, 6e-04)
test.df <- data.frame(id = seq_len(4), pval = test.pval)



# Use the same alpha, tau, lambda as above
alpha_small  <- alpha
tau_small    <- tau
lambda_small <- lambda

# Build gamma for length 4 (n = 4) from the package default formula
n_small <- length(test.pval)
gamma_small_full  <- 0.4374901658 / (seq_len(n_small + 1)^(1.6))
gamma_small_lasse <- gamma_small_full[1:n_small]

## 1) Numeric vector test.pval
alpha_orig_vec <- E_ADDIS_Spending(alpha_small,
                                   gamma_small_lasse,
                                   tau_small,
                                   lambda_small,
                                   test.pval,
                                   n_small)
alpha_orig_vec

res_vec <- ADDIS_exhaustive(test.pval,
                            alpha = alpha_small,
                            tau = tau_small,
                            lambda = lambda_small,
                            gamma = gamma_small_full)
res_vec

ADDIS(test.df)




## 2) data.frame test.df (just use its pval)
alpha_orig_df <- E_ADDIS_Spending(alpha_small,
                                  gamma_small_lasse,
                                  tau_small,
                                  lambda_small,
                                  test.df$pval,
                                  n_small)
R_orig_df <- as.integer(test.df$pval <= alpha_orig_df)
R_orig_df

res_df <- ADDIS_exhaustive(test.df,
                           alpha = alpha_small,
                           tau = tau_small,
                           lambda = lambda_small,
                           gamma = gamma_small_full)
alpha_pkg_df <- res_df$alphai
R_pkg_df     <- res_df$R
R_pkg_df

res_df
ADDIS(test.df3)


###############################################################################
######## Computational time ###########
###############################################################################

set.seed(1)
n_long <- 1e6  
p_long <- runif(n_long)

alpha  <- 0.05
tau    <- 0.5
lambda <- 0.25

system.time({
  res_long <- ADDIS_exhaustive(p_long, alpha = alpha, tau = tau, lambda = lambda)
})

head(res_long, n = 10)


set.seed(2)
n_clust <- 1e6
p_clust <- c(runif(n_clust * 0.1, min = 0, max = 0.01),   # many very small
             runif(n_clust * 0.2, min = 0.01, max = 0.3), # moderate
             runif(n_clust * 0.7, min = 0.3, max = 1.0))  # null-like
p_clust <- p_clust[seq_len(n_clust)]

system.time({
  res_clust <- ADDIS_exhaustive(p_clust, alpha = 0.05, tau = 0.5, lambda = 0.25)
})

table(res_clust$R)

set.seed(3)
n_edge <- 5e4
p_edge <- runif(n_edge)

alpha  <- 0.05
tau    <- 0.51        # close to 0.5
lambda <- 0.5         # very close, but < tau

system.time({
  res_edge <- ADDIS_exhaustive(p_edge, alpha = alpha, tau = tau, lambda = lambda)
})

range(res_edge$alphai)

