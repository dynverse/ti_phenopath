#!/usr/local/bin/Rscript

task <- dyncli::main()

library(dplyr, warn.conflicts = FALSE)
library(purrr, warn.conflicts = FALSE)
library(dynwrap, warn.conflicts = FALSE)
library(phenopath, warn.conflicts = FALSE)

#   ____________________________________________________________________________
#   Load data                                                               ####

parameters <- task$parameters
expression <- as.matrix(task$expression)

#   ____________________________________________________________________________
#   Infer trajectory                                                        ####

# TIMING: done with preproc
checkpoints <- list(method_afterpreproc = as.numeric(Sys.time()))

# run phenopath
fit <- phenopath::phenopath(
  exprs_obj = expression,
  x = rep(1, nrow(expression)),
  elbo_tol = 1e-6,
  thin = parameters$thin,
  z_init = ifelse(parameters$z_init == "random", "random", as.numeric(parameters$z_init)),
  model_mu = parameters$model_mu,
  scale_y = parameters$scale_y
)
pseudotime <- phenopath::trajectory(fit) %>%
  setNames(rownames(expression))

# TIMING: done with method
checkpoints$method_aftermethod <- as.numeric(Sys.time())

# return output
output <- lst(
  cell_ids = names(pseudotime),
  pseudotime,
  timings = checkpoints
)

#   ____________________________________________________________________________
#   Save output                                                             ####

output <- dynwrap::wrap_data(cell_ids = names(pseudotime)) %>%
  dynwrap::add_linear_trajectory(pseudotime = pseudotime) %>%
  dynwrap::add_timings(timings = checkpoints)

output %>% dyncli::write_output(task$output)
