amova.rda <- function(
  x, x.data
)
{
  message("Calculation of AMOVA for a balanced design")
  
  rda.terms <- attributes(x$terms)$term.labels

  if (length(rda.terms) > 2) {stop("Calculations only shown for maximum 2 levels")}
    
  if (length(rda.terms) == 1) {
  message("No higher hierarchical level")  
    
  anova.result <- vegan::anova.cca(x, by="terms", permutations=0)
  print(anova.result)
  Df.all <- c(anova.result$Df, sum(anova.result$Df))
  Variance.all <- c(anova.result$Variance, sum(anova.result$Variance))
  table1 <- data.frame(cbind(Df.all, Variance.all))
  names(table1) <- c("Df", "Variance")
  rownames(table1) <- c(rda.terms, "within.Samples", "Total")
  table1$SumSq <- table1$Variance * (table1[3, "Df"])
  table1$MeanSq <- table1$SumSq / table1$Df

  message(paste("\n", "Sums-of-Squares are calculated by multiplying variance with (number of individuals - 1)"))
  print(table1)   
    
  message("Mean population size:")
  n1 <- mean(table(x.data[, rda.terms[1]]))
  print(n1)   
    
  table2 <- table1[, c(1:2)]
  names(table2) <- c("Covariance", "Percent") 
  table2[2, 1] <- table1[2, "MeanSq"]
  table2[1, 1] <- (table1[1, "MeanSq"] - table2[2, 1]) / n1
  table2[3, 1] <- sum(table2[1:2, 1])
  table2[1, 2] <- 100* table2[1, 1] / table2[3, 1]
  table2[2, 2] <- 100 * table2[2, 1] / table2[3, 1]
  table2[3, 2] <- 100 
  print(table2)     
    
  }
  
  if (length(rda.terms) == 2) {
  message("Population level of '", rda.terms[2], "' nested within higher level of '", rda.terms[1], "'")     
  anova.result <- vegan::anova.cca(x, by="terms", permutations=0)
  print(anova.result)
  Df.all <- c(anova.result$Df, sum(anova.result$Df))
  Variance.all <- c(anova.result$Variance, sum(anova.result$Variance))
  table1 <- data.frame(cbind(Df.all, Variance.all))
  names(table1) <- c("Df", "Variance")
  rownames(table1) <- c(rda.terms, "within.Samples", "Total")
  table1$SumSq <- table1$Variance * (table1[4, "Df"])
  table1$MeanSq <- table1$SumSq / table1$Df

  message(paste("\n", "Sums-of-Squares are calculated by multiplying variance with (number of individuals - 1)"))
  message(paste("The (number of individuals - 1) is also the Df for the total Sum-of-Squares."))
  print(table1)
  
  message("Mean population size:")
  n1 <- mean(table(x.data[, rda.terms[2]]))
  print(n1)
  
  message("Mean sizes of higher level:")
  n2 <- mean(table(x.data[, rda.terms[1]]))
  print(n2)
   
  table2 <- table1[, c(1:2)]
  names(table2) <- c("Covariance", "Percent") 
  table2[3, 1] <- table1[3, "MeanSq"]
  table2[2, 1] <- (table1[2, "MeanSq"] - table2[3, 1]) / n1
  table2[1, 1] <- (table1[1, "MeanSq"] - table2[3, 1] - n1*table2[2, 1]) / n2
  table2[4, 1] <- sum(table2[1:3, 1])
  table2[1, 2] <- 100* table2[1, 1] / table2[4, 1]
  table2[2, 2] <- 100 * table2[2, 1] / table2[4, 1]
  table2[3, 2] <- 100 * table2[3, 1] / table2[4, 1]
  table2[4, 2] <- 100 
  message(paste("\n", "Calculation of covariance"))
  print(table2) 

  PHI <- numeric(length=3)
  names(PHI) <- c("Samples-Total", 
                  "Samples-Pop", 
                  "Pop-Total")
  
  PHI[1] <- (table2[1, 1] + table2[2, 1]) / table2[4, 1]
  PHI[2] <- table2[2, 1] / (table2[2, 1] + table2[3, 1])
  PHI[3] <- table2[1, 1] / (table2[4, 1])   

  message(paste("\n", "Phi statistics"))

  print(PHI)
  }
  
} 