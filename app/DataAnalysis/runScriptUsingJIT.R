args <- commandArgs(trailingOnly = TRUE)
fileToRun <- args[1]

library(compiler)
invisible(enableJIT(3))

source(fileToRun)
