moon.waxer <- function(
  freq.in = NULL, sort.index = "Pop.index",
  mean.change=FALSE, change.FUN=stats::median,  
  freq.focus="Allele.freq", 
  ypos=0, right=TRUE
) 
{

    np <- length(unique(freq.in$Allele))

   if (mean.change == TRUE) {

    freq.columns <- cbind(freq.in$Allele.freq,
                          freq.in$Freq.e2, 
                          freq.in$LCL, 
                          freq.in$UCL)
 
    freq.means <- stats::aggregate(freq.columns ~ freq.in$Pop, FUN=change.FUN)

    names(freq.means)[1] <- "Pop"
    
    freq.means <- dplyr::left_join(freq.in[, c("Pop", "Allele.freq")],
                            freq.means,
                            by="Pop")

    freq.in$Allele.freq <- freq.means$V1
    freq.in$Freq.e2 <- freq.means$V2
    freq.in$LCL <- freq.means$V3
    freq.in$UCL <- freq.means$V4
    
    freq.in <- freq.in[1:np, ]
    freq.in$increasing <- freq.in$Freq.e2 > freq.in$Allele.freq
    freq.in$Allele <- factor(rep("Alleles aggregated", np))
  }   

    for (i in 1:nrow(freq.in)) {
        rowsi <- data.frame(Pop=rep(freq.in[i, "Pop"], 2),
                        sort.index=rep(as.numeric(freq.in[i, sort.index]), 2),
                        Allele=rep(freq.in[i, "Allele"], 2),
                        increasing=rep(freq.in[i, "increasing"], 2),
                        ypos=rep(ypos, 2),
                        state=c("A", "B"),
                        ratio=c(freq.in[i, freq.focus],
                                 (1-freq.in[i, freq.focus])),
                        right=c(TRUE, FALSE),
                        colour=c("baseA", "baseB"))

    if (i == 1) {
      result <- rowsi
    }else{
      result <- rbind(result, rowsi)
    }
  }
 
  result$change.colour <- as.character(result$colour)
  
  for (i in 1:nrow(result)) {
    if (result[i, "state"] == "A") {
      if (result[i, "increasing"] == TRUE) {
        result[i, "change.colour"] <- c("change A increase")
      }
      if (result[i, "increasing"] == FALSE) {
        result[i, "change.colour"] <- c("change A decrease")
      }     
    }
  }

  result$colour <- factor(result$colour,
                                 levels=c("baseA", 
                                          "baseB", 
                                          "change A increase", 
                                          "change A decrease"))
  result$change.colour <- factor(result$change.colour,
                                 levels=c("baseA", 
                                          "baseB", 
                                          "change A increase", 
                                          "change A decrease"))
  
  return(result)
  
}

shift.moon.ggplot <- function(
  baseline.moon, future.moon,   
  manual.colour.values=c("white", "grey", "firebrick3", "chartreuse4"),
  manual.colour.codes=c("A baseline ", "B", "A decreasing", "A increasing")
)
{

    np <- length(unique(baseline.moon$Pop))
  
ggmoonx <- ggplot2::ggplot() +
  ggplot2::scale_x_continuous(limits=c(0.5, np+0.5),
                     breaks=seq(from=1, to=np, by=1),
                     labels=levels(baseline.moon$Pop)) +
  ggplot2::scale_y_continuous(limits=c(-0.5, 1.5)) +
  gggibbous::geom_moon(data=baseline.moon,
            ggplot2::aes(x=baseline.moon$sort.index, y=baseline.moon$ypos, ratio=baseline.moon$ratio, right=baseline.moon$right, fill=baseline.moon$colour),
            size=10, stroke=0.03, col="black") +
  gggibbous::geom_moon(data=future.moon,
            ggplot2::aes(x=future.moon$sort.index, y=future.moon$ypos, ratio=future.moon$ratio, right=future.moon$right, 
                fill=future.moon$change.colour),
            size=10, stroke=0.03, col="black") +
  ggplot2::geom_point(data=subset(future.moon, future.moon$increasing==TRUE),
            ggplot2::aes(x=subset(future.moon, future.moon$increasing==TRUE)$sort.index, y=subset(future.moon, future.moon$increasing==TRUE)$ypos),
            size=3, shape=21, fill=manual.colour.values[4], stroke=0.03, show.legend=FALSE) +
  ggplot2::geom_point(data=subset(future.moon, future.moon$increasing==FALSE),
            ggplot2::aes(x=subset(future.moon, future.moon$increasing==FALSE)$sort.index, y=subset(future.moon, future.moon$increasing==FALSE)$ypos),
            size=3, shape=21, fill=manual.colour.values[3], stroke=0.03, show.legend=FALSE) +
  ggplot2::coord_flip() +
  ggplot2::xlab(ggplot2::element_blank()) +
  ggplot2::ylab(ggplot2::element_blank()) +
  ggplot2::labs(fill=" ") +
  ggplot2::scale_fill_manual(values=manual.colour.values, 
                    labels=c("A baseline ", "B", "A decreasing", "A increasing")) +
  ggplot2::theme(panel.grid = ggplot2::element_blank()) +
  ggplot2::theme(axis.text.x= ggplot2::element_blank()) +
  ggplot2::theme(axis.ticks.x = ggplot2::element_blank())

if (length(unique(baseline.moon$Allele)) > 1 ){

  ggmoonx <- ggmoonx +
    ggplot2::theme(legend.position="top") +
    ggplot2::facet_grid( ~ Allele, scales="free")
}

return(ggmoonx)

}







