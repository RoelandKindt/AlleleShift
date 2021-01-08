freq.ggplot <- function(
  freq.predicted, plot.best=TRUE, threshold=0.50, 
  colour.Pop=TRUE, manual.colour.values=NULL,
  xlim=c(0.0, 1.0), ylim=c(0.0, 1.0)
)
{

  np <- length(unique(freq.predicted$Pop))
  
  manual.colour <- data.frame(values=manual.colour.values)
  
  lm.Rsq <- data.frame(Pop=freq.predicted[1:np, "Pop"],
                       Pop.label=as.character(c(1:np)),
                       N=freq.predicted[1:np, "N"]/2,
                       GAM.rsq=numeric(np))

  for (p1 in 1:np) {
    Pop.focal <- freq.predicted[p1, "Pop"]
    long.p <- freq.predicted[freq.predicted$Pop == Pop.focal, ]
    m <- stats::lm(Freq.e2 ~ Allele.freq, data=long.p)
    lm.Rsq[p1, "GAM.rsq"] <- round(summary(m)$r.squared, 2)
  }

  message("Populations ordered by R2")
  print(lm.Rsq[order(lm.Rsq$GAM.rsq, decreasing=TRUE), ])

  lm.Rsq$Pop.legend <- paste0(lm.Rsq$Pop, " (P", 
                              lm.Rsq$Pop.label, ") : ",
                              format(lm.Rsq$GAM.rsq, digits=2))

  freq.predicted <- dplyr::left_join(freq.predicted,
                              lm.Rsq[, c("Pop.label", "Pop.legend")],
                              by= "Pop.label")
  
  if (plot.best == TRUE) {
    good.pops <- lm.Rsq[lm.Rsq$GAM >= threshold, "Pop"]
  }else{
    good.pops <- lm.Rsq[lm.Rsq$GAM <= threshold, "Pop"]
  }
  
  message("selected populations")
  print(good.pops)
  
  sqrt.data <- data.frame(x=seq(from=0, to=1, by=0.001))
  sqrt.data$y <- sqrt.data$x
  sqrt.data$y1 <- sqrt.data$x+0.05
  sqrt.data$y2 <- sqrt.data$x-0.05

  BioR.theme <- ggplot2::theme(
        panel.background = ggplot2::element_blank(),
        panel.border = ggplot2::element_blank(),
        panel.grid = ggplot2::element_blank(),
        axis.line = ggplot2::element_line("gray25"),
        text = ggplot2::element_text(size = 12),
        axis.text = ggplot2::element_text(size = 10, colour = "gray25"),
        axis.title = ggplot2::element_text(size = 10, colour = "gray25"),
        legend.title = ggplot2::element_text(size = 10),
        legend.text = ggplot2::element_text(size = 10),
        legend.key = ggplot2::element_blank())


  if (colour.Pop == TRUE) {
  ggplotx <- ggplot2::ggplot() +
    ggplot2::scale_x_sqrt(limits=xlim) +
    ggplot2::scale_y_continuous(limits=ylim,
                       sec.axis = ggplot2::dup_axis(labels=NULL, name=NULL)) +
    ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y),
            color = "darkolivegreen4", linetype = 1, size=2) +  
    ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y1),
            color = "darkolivegreen4", linetype = 2, size=1) + 
    ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y2),
            color = "darkolivegreen4", linetype = 2, size=1) + 
    ggplot2::geom_hline(yintercept = c(0.1), color = "black", linetype = 2) + 
    ggplot2::geom_vline(xintercept = c(0.000000000000001), color = "black", linetype = 2) +
    ggplot2::geom_vline(xintercept = c(0.1), color = "black", linetype = 2) +  
    ggplot2::geom_point(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
             ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
             		y=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Freq.e2, 
             		colour=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Pop.legend),
             	size=4, alpha=0.8) +
    ggplot2::geom_errorbar(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
                ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
                    ymin=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$LCL, 
                    ymax=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$UCL, 
                    colour=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Pop.legend),
                width=0.02, show.legend=FALSE) +
    ggplot2::geom_text(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
             ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
                 y=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Freq.e2, 
                 label=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Pop.label),
             colour="black", size=2.5, alpha=1.0, show.legend=FALSE) +
    ggplot2::xlab("Actual allele frequency") +
    ggplot2::ylab("Predicted allele frequency") +
    ggplot2::labs(colour=expression("Population : R"^2)) +
    BioR.theme


  }else{
    
   ggplotx <- ggplot2::ggplot() +
    ggplot2::scale_x_sqrt(limits=xlim) +
    ggplot2::scale_y_continuous(limits=ylim,
                       sec.axis = ggplot2::dup_axis(labels=NULL, name=NULL)) +
      ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y),
            color = "darkolivegreen4", linetype = 1, size=2) +  
      ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y1),
            color = "darkolivegreen4", linetype = 2, size=1) + 
      ggplot2::geom_line(data=sqrt.data,
            ggplot2::aes(x=sqrt.data$x, y=sqrt.data$y2),
            color = "darkolivegreen4", linetype = 2, size=1) + 
      ggplot2::geom_hline(yintercept = c(0.1), color = "black", linetype = 2) +
      ggplot2::geom_vline(xintercept = c(0.000000000000001), color = "black", linetype = 2) +
      ggplot2::geom_vline(xintercept = c(0.1), color = "black", linetype = 2) +  
      ggplot2::geom_point(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
             ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
             	y=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Freq.e2, 
             	colour=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele),
             size=4, alpha=0.8) +
      ggplot2::geom_errorbar(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
                ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
                ymin=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$LCL, 
                ymax=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$UCL, 
                colour=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele),
                width=0.02, show.legend=FALSE) +
      ggplot2::geom_text(data=subset(freq.predicted, freq.predicted$Pop %in% good.pops),
             ggplot2::aes(x=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Allele.freq, 
             y=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Freq.e2, 
             label=subset(freq.predicted, freq.predicted$Pop %in% good.pops)$Pop.label),
             colour="black", size=2.5, alpha=1.0, show.legend=FALSE) +
      ggplot2::xlab("Actual allele frequency") +
      ggplot2::ylab("Predicted allele frequency") +
      ggplot2::labs(colour=expression("Population : R"^2)) +
      BioR.theme

  }

  if(is.null(manual.colour.values) == FALSE) {
    ggplotx <- ggplotx + 
      ggplot2::scale_colour_manual(values=as.character(manual.colour$values))    
  }
  
 return(ggplotx)
  
}





