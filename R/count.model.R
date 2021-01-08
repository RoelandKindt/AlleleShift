count.model <- function(
  genpop.data, env.data, permutations=99, 
  ordistep=FALSE, cca.model=FALSE
)
{
  gen.comm <- data.frame(genpop.data@tab)
  gen.freq <- data.frame(adegenet::makefreq(genpop.data))

  row.ratios <- rowSums(gen.comm) / max(rowSums(gen.comm))
  gen.comm.b <- gen.comm
  for (i in 1:nrow(gen.comm)) {gen.comm.b[i,] <- gen.comm[i, ] / row.ratios[i]}
  rda.baseline <- vegan::rda(gen.comm.b ~ ., data=env.data)
  print(summary(rda.baseline))

  if (permutations > 0){
    print(vegan::anova.cca(rda.baseline, permutations=permutations))
    print(vegan::anova.cca(rda.baseline, by="terms", permutations=permutations))
    print(vegan::anova.cca(rda.baseline, by="margin", permutations=permutations))
  }

  if (ordistep == TRUE) {
    rda.null <- vegan::rda(gen.comm.b ~ 1, data=env.data)
    rda.reduced <- vegan::ordistep(rda.null, 
                            scope=stats::formula(rda.baseline), 
                            direction = "both")
    
    cat(paste("Reduced model:", "\n"))
    print(vegan::anova.cca(rda.reduced, permutations=permutations))
    print(vegan::anova.cca(rda.reduced, by="terms", permutations=permutations))
    print(vegan::anova.cca(rda.reduced, by="margin", permutations=permutations))   

#    rda.baseline <- rda.reduced
  }

  if (cca.model == TRUE) {
      c.index <- seq(from=1, to=(ncol(gen.comm)-1), by=2)
      gen.freq.c <- gen.freq[, c.index]  
      cca.baseline <- vegan::cca(gen.freq.c ~ ., data=env.data)
      print(summary(cca.baseline))
      
      if (ordistep == TRUE) {
          cca.null <- vegan::cca(gen.freq.c ~ 1, data=env.data)
          cca.reduced <- ordistep(cca.null, 
                                  scope=stats::formula(cca.baseline), 
                                  direction = "both")
          cat(paste("Reduced model (CCA):", "\n"))
          print(vegan::anova.cca(cca.reduced, permutations=permutations))
          print(vegan::anova.cca(cca.reduced, by="terms", permutations=permutations))
          print(vegan::anova.cca(cca.reduced, by="margin", permutations=permutations)) 
      }
  }else{
      cca.baseline <- NULL
  }

  result <- list(rda.model=rda.baseline, 
                 row.ratios=row.ratios,
                 gen.comm=gen.comm,
                 gen.freq=gen.freq,
                 cca.model=cca.baseline)

  return(result)
  
}

count.pred <- function(
  count.model, env.data
)
{
  predict.rda2 <- utils::getS3method("predict", "rda")
  comm.pred <- predict.rda2(count.model$rda.model, newdata=env.data)
  comm.pred2 <- comm.pred
  row.ratios <- count.model$row.ratios
  
  for (i in 1:nrow(comm.pred2)) {comm.pred2[i, ] <- comm.pred[i, ] * row.ratios[i]}

  if (is.null(count.model$cca.model) == FALSE) {
      predict.cca2 <- utils::getS3method("predict", "cca")
      freq.pred2 <- predict.cca2(count.model$cca.model, newdata=env.data)     
  }

  actual <- count.model$gen.comm
  np <- nrow(actual)
  actual$N <- rowSums(actual) / ncol(actual)
  gen.freq <- count.model$gen.freq
  
  c.index <- seq(from=1, to=(ncol(actual)-1), by=2) 

  for (c in c(1:length(c.index))){
    allc.res <- data.frame(Pop=rownames(actual),
                           Pop.label=as.character(c(1:np)),
                           Pop.index=as.numeric(c(1:np)),
                           N=2*actual$N, # diploid
                           Allele=rep(names(actual)[c.index[c]], np),
                           Allele.freq=gen.freq[, c.index[c]],
                           A=actual[, c.index[c]],
                           B=actual[, c.index[c]+1],
                           Ap=comm.pred2[, c.index[c]],
                           Bp=comm.pred2[, c.index[c]+1])

    if (is.null(count.model$cca.model) == FALSE) {
      c1 <- (c+1)/2
      allc.res$Freq.Blumstein <- freq.pred2[, c1]    
    }

    if (c == 1) {
      all.res <- allc.res 
    }else{
      all.res <- rbind(all.res, allc.res)
    }  
  }

  all.res$N.e1 <- all.res$Ap + all.res$Bp
  all.res$Freq.e1 <- (all.res$Ap) / all.res$N.e1

  return(all.res)

}

freq.model <- function(
  count.predicted
)
{
  mgcv.model <- mgcv::gam(formula= cbind(A, B) ~ s(Freq.e1), 
                          data=count.predicted,
                          family=stats::binomial(link="logit"))

  print(summary(mgcv.model))
  
  return(mgcv.model)
}

freq.pred <- function(
  freq.model, count.predicted
)
{
  predsx <- mgcv::predict.gam(freq.model, 
                    newdata=count.predicted,
                    type="response",
                    se.fit=TRUE) 

  np <- length(unique(count.predicted$Pop))
  
  count.predicted$Freq.e2 <- predsx$fit
  count.predicted$LCL <- predsx$fit - stats::qt(0.95, df=(np-1))*predsx$se.fit
  count.predicted$UCL <- predsx$fit + stats::qt(0.95, df=(np-1))*predsx$se.fit
  
  count.predicted[count.predicted$LCL < 0.0, "LCL"] <- 0.0
  count.predicted[count.predicted$UCL > 1.0, "UCL"] <- 1.0
  
  count.predicted$increasing <- count.predicted$Freq.e2 > count.predicted$Allele.freq 
  
  return(count.predicted)
}

