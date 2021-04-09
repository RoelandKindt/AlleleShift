\name{shift.pie.ggplot}
\alias{shift.pie.ggplot}
\alias{pie.baker}

\title{Shifts of Allele Frequencies as Response to Climate Change}

\description{
The function shows changes in allele frequencies between the baseline and future/past climate.
}

\usage{

shift.pie.ggplot(baseline.pie, future.pie,
	manual.colour.values = c("black", "grey", "firebrick3", "chartreuse4"),
	manual.colour.codes = c("A baseline ", "B", "A decreasing", "A increasing"))

pie.baker(freq.in, sort.index= "Pop.index",
	mean.change = FALSE, change.FUN = stats::median,
	freq.focus = "Allele.freq", ypos = 0,
	r0 = 0.1, r = 0.5, focus = 0.2 )

}

\arguments{

\item{baseline.pie, future.pie}{ Result from \code{AlleleShift::pie.baker}. }
\item{manual.colour.values}{ Colours to be used in the plot. }
\item{manual.colour.codes}{ Sequence for the manual colour values. }

\item{freq.in}{ Result from \code{AlleleShift::predFreq}. }
\item{sort.index}{ Sequence of the populations in the plot.}
\item{mean.change}{ Aggregate changes among alleles. }
\item{change.FUN}{ Function used the aggregate changes. }
\item{freq.focus}{ Allele frequency for which to calculate statistics, either 'Allele.freq' or 'Freq.e2'. }
\item{ypos, r0, r, focus}{ Arguments used for plotting, mainly as in \code{\link[ggforce]{geom_arc_bar}} } 
  
}


\value{
The function generates a ggplot that depicts changes between baseline and future/past allele frequencies of the populations.
}

\seealso{
\code{\link{shift.dot.ggplot}}, \code{\link{shift.moon.ggplot}}, \code{\link{shift.waffle.ggplot}}, \code{\link{shift.surf.ggplot}}
}

\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

# The data can be obtained via the count.model and freq.model calibrations.
# These procedures are not repeated here.
data(Poptri.freq.baseline)
data(Poptri.freq.future)

Poptri.baseline.pie <- pie.baker(Poptri.freq.baseline, r0=0.1,
                                 sort.index="Latitude.index")

Poptri.future.pie <- pie.baker(Poptri.freq.future, r0=0.1, 
                        freq.focus="Freq.e2",
                        sort.index="Latitude.index",
                        ypos=1)

ggpie1 <- shift.pie.ggplot(Poptri.baseline.pie, 
                           Poptri.future.pie)
ggpie1


# create an animation

\dontrun{

library(ggplot2)
library(ggforce)
library(gganimate)
library(gifski)
library(transformr)

# The data is an interpolation and extrapolation between the baseline and future climate.
# For actual application, interpolate between climate data from available sources

data(Poptri.1985to2085)

decades <- sort(unique(Poptri.1985to2085$Decade))

for (d in 1:length(decades)) {
  decade.focal <- decades[d]
  decade.data <- Poptri.1985to2085[Poptri.1985to2085$Decade == decade.focal, ]
  decade.pie <- pie.baker(decade.data, r0=0.1, 
                        freq.focus="Freq.e2",
                        sort.index="Latitude.index",
                        ypos=1)
  decade.pie <- cbind(Decade=rep(decade.focal, nrow(decade.pie)), decade.pie)
  
  if (d == 1) {
    future.pies <- decade.pie
  }else{
    future.pies <- rbind(future.pies, decade.pie)
  }
}

np <- length(unique(Poptri.baseline.pie$Pop))
manual.colour.values <- c("black", "grey", "firebrick3", "chartreuse4")
  
ggpie.all <- ggplot(data=future.pies, group=Decade) +
  scale_x_continuous(limits=c(0.5, np+0.5),
                     breaks=seq(from=1, to=np, by=1),
                     labels=levels(Poptri.baseline.pie$Pop)) +
  geom_arc_bar(data=Poptri.baseline.pie,
               aes(x0=sort.index, y0=ypos, r0=r0, r=0.4, 
                   start=start, end=end, fill=colour),
               size=0.04, alpha=1, colour="snow1") +                    
  geom_arc_bar(data=future.pies,
               aes(x0=sort.index, y0=ypos, r0=r0, r=0.4, 
                   start=start, end=end, fill=change.colour),
               size=0.04, alpha=1, colour="snow1") + 
  geom_point(data=subset(future.pies, increasing==TRUE),
            aes(x=sort.index, y=ypos),
            size=5, shape=21, fill=manual.colour.values[4], stroke=0.03, show.legend=FALSE) +
  geom_point(data=subset(future.pies, increasing==FALSE),
            aes(x=sort.index, y=ypos),
            size=5, shape=21, fill=manual.colour.values[3], stroke=0.03, show.legend=FALSE) +
  coord_flip() +
  xlab(element_blank()) +
  ylab(element_blank()) +
  labs(fill=" ") +
  scale_fill_manual(values=manual.colour.values, 
                    labels=c("A baseline ", "B", "A decreasing", "A increasing")) +
  theme(panel.grid = element_blank()) +
  theme(axis.text.x=element_blank()) +
  theme(axis.ticks.x = element_blank()) +
  theme(legend.position="top") +
  facet_grid( ~ Allele, scales="free")

ggpie.all
  
# note this will take quite a while!
ggpie.anim <- ggpie.all + 
  transition_states(as.factor(Decade), transition_length = 10, state_length = 100) +
  labs(title = "Decade: {closest_state}s")

ggpie.anim2 <- animate(ggpie.anim, fps=5, width=1280, height=720)

getwd()
anim_save(filename="Allele shift pie animation.gif", animation=ggpie.anim2)

}

}




