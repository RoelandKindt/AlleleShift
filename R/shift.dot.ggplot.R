shift.dot.ggplot <- function(
  freq.future,
  mean.change=FALSE, change.FUN=stats::median,
  baseline.colour="black",
  future.colour="dodgerblue3",
  manual.colour.values=c("firebrick3", "chartreuse4")
)
{

    np <- length(unique(freq.future$Pop))

  if (mean.change == TRUE) {

    freq.columns <- cbind(freq.future$Allele.freq,
                          freq.future$Freq.e2,
                          freq.future$LCL,
                          freq.future$UCL)

    freq.means <- stats::aggregate(freq.columns ~ freq.future$Pop, FUN=change.FUN)

    names(freq.means)[1] <- "Pop"

    freq.means <- dplyr::left_join(freq.future[, c("Pop", "Allele.freq")],
                            freq.means,
                            by="Pop")

   # print(freq.means)

    freq.future$Allele.freq <- freq.means$V1
    freq.future$Freq.e2 <- freq.means$V2
    freq.future$LCL <- freq.means$V3
    freq.future$UCL <- freq.means$V4

    freq.future <- freq.future[1:np, ]
    freq.future$increasing <- freq.future$Freq.e2 > freq.future$Allele.freq

    freq.future$Allele <- factor(rep("Alleles aggregated", np))

  }

  freq.future$increasing <- factor(freq.future$increasing,
                                   levels=c("TRUE", "FALSE"))

  ggdotx <- ggplot2::ggplot(data=freq.future) +
    ggplot2::geom_errorbar(ggplot2::aes(x=freq.future$Pop, ymin=freq.future$LCL, ymax=freq.future$UCL),
                colour="grey30", width=0.9, show.legend=FALSE) +
    ggplot2::geom_segment(ggplot2::aes(x=freq.future$Pop, y=freq.future$Allele.freq, xend=freq.future$Pop, yend=freq.future$Freq.e2, colour=freq.future$increasing),
               size=1.2) +
    ggplot2::geom_point(ggplot2::aes(x=freq.future$Pop, y=freq.future$Allele.freq),
             colour=baseline.colour, size=6, alpha=0.7) +
    ggplot2::geom_point(ggplot2::aes(x=freq.future$Pop, y=freq.future$Freq.e2),
             colour=future.colour, size=6, alpha=0.7) +
    ggplot2::coord_flip() +
    ggplot2::xlab(ggplot2::element_blank()) +
    ggplot2::ylab("Allele frequencies") +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank()) +
    ggplot2::labs(colour="Predicted change in allele frequencies") +
    ggplot2::scale_colour_manual(values=manual.colour.values,
                                 breaks=c("FALSE", "TRUE"),
                                 labels=c("decreasing", "increasing")) +
    ggplot2::theme(axis.text.x=ggplot2::element_text(angle=90, vjust=0.5, size=10)) +
    ggplot2::theme(legend.position="top")

  if (length(unique(freq.future$Allele)) > 1 ){
  ggdotx <- ggdotx +
    ggplot2::facet_grid( ~ Allele, scales="free")
  }

return(ggdotx)

}


