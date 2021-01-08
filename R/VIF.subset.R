VIF.subset <- function(
  data, VIF.max=20,
  keep=NULL, silent=FALSE,
  cor.plot=TRUE
)
{

  R2 <- 1- 1/VIF.max

  if (is.null(keep) == FALSE) {
    cor1 <- stats::cor(data)
    cor1[cor1 > R2] <- 100
    
    exclude.vars <- c()
    keep.vars <- c()
    
    for (i in 1:length(keep)) {
        exclude.vars <- c(exclude.vars,
                          which(cor1[, keep[i]] >= 100))
    }
    exclude.vars <- unique(exclude.vars)
    exclude.vars <- names(data)[exclude.vars]
    for (i in 1:ncol(data)) {
      if ((names(data)[i] %in% exclude.vars) == FALSE) {
          keep.vars <- c(keep.vars, i)
        }
    }
    keep.vars <- unique(keep.vars)
    keep.vars <- names(data)[keep.vars]
    keep.vars <- unique(c(keep, keep.vars))
    cat(paste("Step 1: Keeping these vars:", "\n"))
    print(keep.vars)
    data <- data[, which(names(data) %in% keep.vars)]    
  }
  
  VIF.result <- BiodiversityR::ensemble.VIF.dataframe(data, VIF.max=VIF.max, 
                                       keep=keep, silent=silent)
  
  if (cor.plot == TRUE) {
    data <- data[, which(names(data) %in% VIF.result$vars.included)]
    cp <- GGally::ggcorr(data, nbreaks=8, palette="RdGy",
                  label=TRUE, label_size=5, digits=3, label_color="white")
    return(list(VIF=VIF.result, cp=cp))
  }else{
    return(VIF.result)
  }   
  
}  