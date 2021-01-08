pie.baker <- function(
  freq.in = NULL, sort.index = "Pop.index",
  mean.change=FALSE, change.FUN=stats::median,  
  freq.focus="Allele.freq", ypos=0, 
  r0=0.1, r=0.5, focus=0.2
) 
{
 
  np <- length(unique(freq.in$Pop))
  
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
                        amount=c(freq.in[i, freq.focus],
                                 (1-freq.in[i, freq.focus])),
                        start=c(0, (freq.in[i, freq.focus]*2*pi)),
                        end=c((freq.in[i, freq.focus]*2*pi), 2*pi),
                        r0=rep(r0, 2),
                        r=rep(r, 2),
                        focus=c(focus, 0),
                        colour=c("baseA", "baseB"))
  
    if (i == 1) {
      result <- rowsi
    }else{
      result <- data.frame(rbind(result, rowsi))
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

shift.pie.ggplot <- function(
  baseline.pie, future.pie, 
  manual.colour.values=c("black", "grey", "firebrick3", "chartreuse4"),
  manual.colour.codes=c("A baseline ", "B", "A decreasing", "A increasing")
)
{

  np <- length(unique(baseline.pie$Pop))
  
ggpiex <- ggplot2::ggplot() +
  ggplot2::scale_x_continuous(limits=c(0.5, np+0.5),
                     breaks=seq(from=1, to=np, by=1),
                     labels=levels(baseline.pie$Pop)) +
  ggforce::geom_arc_bar(data=baseline.pie,
               ggplot2::aes(x0=baseline.pie$sort.index, y0=baseline.pie$ypos, r0=baseline.pie$r0, r=0.4, 
                   start=baseline.pie$start, end=baseline.pie$end, fill=baseline.pie$colour),
               size=0.04, alpha=1, colour="snow1") +                    
  ggforce::geom_arc_bar(data=future.pie,
               ggplot2::aes(x0=future.pie$sort.index, y0=future.pie$ypos, r0=future.pie$r0, r=0.4, 
                   start=future.pie$start, end=future.pie$end, fill=future.pie$change.colour),
               size=0.04, alpha=1, colour="snow1") + 
  ggplot2::geom_point(data=subset(future.pie, future.pie$increasing==TRUE),
            ggplot2::aes(x=subset(future.pie, future.pie$increasing==TRUE)$sort.index, y=subset(future.pie, future.pie$increasing==TRUE)$ypos),
            size=5, shape=21, fill=manual.colour.values[4], stroke=0.03, show.legend=FALSE) +
  ggplot2::geom_point(data=subset(future.pie, future.pie$increasing==FALSE),
            ggplot2::aes(x=subset(future.pie, future.pie$increasing==FALSE)$sort.index, y=subset(future.pie, future.pie$increasing==FALSE)$ypos),
            size=5, shape=21, fill=manual.colour.values[3], stroke=0.03, show.legend=FALSE) +
  ggplot2::coord_flip() +
  ggplot2::xlab(ggplot2::element_blank()) +
  ggplot2::ylab(ggplot2::element_blank()) +
  ggplot2::labs(fill=" ") +
  ggplot2::scale_fill_manual(values=manual.colour.values, 
                    labels=c("A baseline ", "B", "A decreasing", "A increasing")) +
  ggplot2::theme(panel.grid = ggplot2::element_blank()) +
  ggplot2::theme(axis.text.x= ggplot2::element_blank()) +
  ggplot2::theme(axis.ticks.x = ggplot2::element_blank())

if (length(unique(baseline.pie$Allele)) > 1 ){

  ggpiex <- ggpiex +
    ggplot2::theme(legend.position="top") +
    ggplot2::facet_grid( ~ Allele, scales="free")
}
  
  return(ggpiex)

}




