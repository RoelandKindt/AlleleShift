shift.surf.ggplot <- function(
  freq.future, 
  Allele.focus=unique(freq.future$Allele)[1],
  freq.focus="Allele.freq",
  xcoord="LON", ycoord="LAT", 
  mean.change=FALSE, change.FUN=stats::median,
  manual.colour.values=c("firebrick3", "chartreuse4"),
  ...
)
{
    np <- length(unique(freq.future$Pop))
 
    freq.future$xcoord <- freq.future[, xcoord]
    freq.future$ycoord <- freq.future[, ycoord]
 
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
    Allele.focus <- paste("Alleles aggregated")
    
  }else{  
    freq.future <- freq.future[freq.future$Allele == Allele.focus, ]
  }

    freq.future$freq.focus <- freq.future[, freq.focus]    
        
plotLONLAT <- vegan::ordiplot(freq.future[, c("xcoord", "ycoord")]) 
surfAllele <- BiodiversityR::ordisurfgrid.long(vegan::ordisurf(plotLONLAT, y=freq.future$freq.focus, ...))

ggsurfx <- ggplot2::ggplot() +
  ggplot2::geom_contour_filled(data=surfAllele, 
                        ggplot2::aes(x=surfAllele$x, y=surfAllele$y, z=surfAllele$z)) +
  ggplot2::geom_point(data=freq.future,
             ggplot2::aes(x=freq.future$xcoord, y=freq.future$ycoord, size=freq.future$freq.focus, colour=freq.future$increasing, shape=freq.future$increasing),
             alpha=0.8, stroke=2, show.legend=FALSE) +
  ggplot2::geom_point(data=freq.future,
             ggplot2::aes(x=freq.future$xcoord, y=freq.future$ycoord, size=freq.future$freq.focus, shape=freq.future$increasing),
             colour="black", alpha=0.8, stroke=0.5, show.legend=FALSE) +
  ggplot2::geom_point(data=freq.future,
             ggplot2::aes(x=freq.future$xcoord, y=freq.future$ycoord, colour=freq.future$increasing),
             shape="square", alpha=0.8, stroke=0.5, show.legend=FALSE) +
  ggplot2::xlab(ggplot2::element_blank()) +
  ggplot2::ylab(ggplot2::element_blank()) +
  ggplot2::labs(fill=Allele.focus) +
  ggplot2::scale_fill_viridis_d() +
  ggplot2::scale_colour_manual(values=manual.colour.values,
                      guide=FALSE) +
  ggplot2::scale_size_area(max_size=6) +
  ggplot2::scale_shape_manual(values=c(6, 2)) +
  ggplot2::theme(panel.grid = ggplot2::element_blank()) +
  ggplot2::theme(axis.text= ggplot2::element_blank()) +
  ggplot2::theme(axis.ticks = ggplot2::element_blank()) +
  ggplot2::theme(legend.title  = ggplot2::element_text(size=9)) +
  ggplot2::theme(legend.text  = ggplot2::element_text(size=8)) +
  ggplot2::coord_fixed()

return(ggsurfx)

}    

