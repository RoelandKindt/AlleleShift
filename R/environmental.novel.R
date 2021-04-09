environmental.novel <- function(
  baseline.env.data, future.env.data
)
{
  np <- nrow(baseline.env.data)
  out <- data.frame(array(dim=c(np, 9)))
  names(out) <- c("Pop", "Var", "Min", "Mean", "Max", "SD",
                  "Future.val", "Novel", "Novel.stat")
  out$Novel <- FALSE
  out$Novel.stat <- Inf

  for (i in c(1:np)) {

    out[i, 1] <- rownames(baseline.env.data)[i]

    for (j in c(1:ncol(baseline.env.data))) {
      var.f <- names(baseline.env.data)[j]

      base.data <- baseline.env.data[, which(names(baseline.env.data) == var.f)]
      base.min <- min(base.data)
      base.mean <- mean(base.data)
      base.max <- max(base.data)
      base.SD <- stats::sd(base.data)

      fut.val <- future.env.data[i, which(names(future.env.data) == var.f)]

      if (fut.val < base.min) {
        out[i, "Novel"] <- TRUE

        stat1 <- stats::pnorm(fut.val, mean=base.mean, sd=base.SD)

        if (stat1 < out[i, "Novel.stat"]) {
          out[i, "Var"] <- var.f
          out[i, "Min"] <- base.min
          out[i, "Mean"] <- base.mean
          out[i, "Max"] <- base.max
          out[i, "SD"] <- base.SD
          out[i, "Future.val"] <- fut.val
          out[i, "Novel.stat"] <- stat1
        }
      }

      if (fut.val > base.max) {
        out[i, "Novel"] <- TRUE
        stat1 <- 1 - stats::pnorm(fut.val, mean=base.mean, sd=base.SD)

        if (stat1 < out[i, "Novel.stat"]) {
          out[i, "Var"] <- var.f
          out[i, "Min"] <- base.min
          out[i, "Mean"] <- base.mean
          out[i, "Max"] <- base.max
          out[i, "SD"] <- base.SD
          out[i, "Future.val"] <- fut.val
          out[i, "Novel.stat"] <- stat1
        }
      }
    }

  }

  return(out)

}

