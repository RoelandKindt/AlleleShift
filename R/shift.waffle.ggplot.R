waffle.baker <- function(
  freq.in = NULL, sort.index = "Pop.index",
  mean.change=FALSE, change.FUN=stats::median
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

waffle.iron <- function(freq, A.value="base A") {
    data0 <- rbind(as.character(rep(200, 12)),
                   as.character(c(200, 1:10, 200)),
                   as.character(c(200, 11:20, 200)),
                   as.character(c(200, 21:30, 200)),
                   as.character(c(200, 31:40, 200)),
                   as.character(c(200, 41:50, 200)),
                   as.character(c(200, 51:60, 200)),
                   as.character(c(200, 61:70, 200)),
                   as.character(c(200, 71:80, 200)),
                   as.character(c(200, 81:90, 200)),
                   as.character(c(200, 91:100, 200)),
                   as.character(rep(200, 12)))

    freq0 <- round(100*freq, 0)
    data0[suppressWarnings(as.numeric(data0)) <= freq0] <- A.value
    data0[suppressWarnings(as.numeric(data0)) == 200] <- c("background")
    data0[suppressWarnings(as.numeric(data0)) > freq0] <- c("base B")

    return(data0)

  }

  for (i in 1:nrow(freq.in)) {

    if (i/100 == round(i/100)) {message(paste("Reached row: ", i, "out of ", nrow(freq.in)))}

    sort.start.i <- 12*as.numeric(freq.in[i, sort.index]) - 11
    sort.end.i <- sort.start.i + 11

    rows.i.left <- data.frame(Pop=rep(freq.in[i, "Pop"], 12),
                              sort.index=seq(from=sort.start.i, to=sort.end.i),
                              Allele=rep(freq.in[i, "Allele"], 12))

    waffle.left.i <- data.frame(waffle.iron(freq.in[i, "Allele.freq"]))
    freq.fut <- as.numeric(freq.in[i, "Freq.e2"])
    if (freq.in[i, "increasing"] == TRUE) {
      waffle.right.i <- data.frame(waffle.iron(freq.fut, A.value="change A increase"))
    }else{
      waffle.right.i <- data.frame(waffle.iron(freq.fut, A.value="change A decrease"))
    }

    double.waffle.i <- cbind(rows.i.left,
                         waffle.left.i,
                         waffle.right.i)

    if (i == 1) {
      waffle.grid <- double.waffle.i
    }else{
      waffle.grid <- rbind(waffle.grid, double.waffle.i)
    }
  }

  for (c.index in 4:ncol(waffle.grid)) {
    waffle.lines <- data.frame(waffle.grid[, c(1:3)],
                               x.pos=rep((c.index-3), nrow(waffle.grid)),
                               colour=waffle.grid[, c.index])

    if (c.index == 4) {
      result <- waffle.lines
    }else{
      result <- rbind(result, waffle.lines)
    }
  }

  result$line.colour <- as.character(rep(NA, nrow(result)))
  result[result$colour == "base A", "line.colour"] <- c("black")
  result[result$colour == "base B", "line.colour"] <- c("white")
  result[result$colour == "change A increase", "line.colour"] <- c("black")
  result[result$colour == "change A decrease", "line.colour"] <- c("black")

  result$colour <- factor(result$colour, levels=c("background", "base A", "base B", "change A decrease", "change A increase"))

return(result)

}


shift.waffle.ggplot <- function(
  future.waffle,
  manual.colour.values=c("black", "grey", "firebrick3", "chartreuse4"),
  manual.colour.codes=c("A baseline ", "B", "A decreasing", "A increasing")
)
{

    np <- length(unique(future.waffle$Pop))

ggwafflex <- ggplot2::ggplot(future.waffle) +

  ggplot2::scale_y_continuous(breaks=seq(from=7, to=12*(np-1)+7, length.out=np),
                     labels=levels(future.waffle$Pop)) +
  ggplot2::geom_tile(ggplot2::aes(x=future.waffle$x.pos, y=future.waffle$sort.index, fill=future.waffle$colour, colour=future.waffle$line.colour)) +
  ggplot2::xlab(ggplot2::element_blank()) +
  ggplot2::ylab(ggplot2::element_blank()) +
  ggplot2::labs(fill=" ") +
  ggplot2::scale_fill_manual(values=c(NA, manual.colour.values),
#                    breaks=c("", "baseA", "baseB", "change A decrease", "change A increase"),
                    labels=c("Allele", "A baseline ", "B", "A decreasing", "A increasing")) +
  ggplot2::scale_colour_manual(values=c(manual.colour.values[2], "white"),
                      guide=FALSE) +
  ggplot2::theme(panel.grid = ggplot2::element_blank()) +
  ggplot2::theme(axis.text.x= ggplot2::element_blank()) +
  ggplot2::theme(axis.ticks.x = ggplot2::element_blank())

if (length(unique(future.waffle$Allele)) > 1 ){

  ggwafflex <- ggwafflex +
    ggplot2::theme(legend.position="top") +
    ggplot2::facet_grid( ~ Allele, scales="free")
}

return(ggwafflex)

}

