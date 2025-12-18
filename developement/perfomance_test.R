library(readr)

devtools::load_all()


df <- read.csv("IMPC_ProcessedData_Continuous.csv")
pval  <- df$Sex.P.Val

alpha  <- 0.05
tau    <- 0.5
lambda <- 0.25
n      <- length(pval)
gamma_full  <- 0.4374901658 / (seq_len(n + 1)^(1.6))

res <- ADDIS_exhaustive(d = pval,
                        alpha = alpha,
                        tau = tau,
                        lambda = lambda,
                        gamma = NULL)
head(res, 20)

pval[is.na(pval)]



dataf  <- data.frame(pval = pval, decision.times = seq_len(n) + 1)
library(future)
future::plan(cluster)
res2  <- ADDIS(d = dataf,
                alpha = alpha,
                tau = tau,
                lambda = lambda,
                display_progress = TRUE)
head(res2, 20)
