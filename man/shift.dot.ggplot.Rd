\name{shift.dot.ggplot}
\alias{shift.dot.ggplot}

\title{Shifts of Allele Frequencies as Response to Climate Change}

\description{
The function shows changes in allele frequencies between the baseline and future/past climate.
}

\usage{

shift.dot.ggplot(freq.future,
	mean.change = FALSE, change.FUN = stats::median,
	baseline.colour = "black",
	future.colour = "dodgerblue3",
	manual.colour.values=c("firebrick3", "chartreuse4"))

}

\arguments{

\item{freq.future}{ Result from \code{AlleleShift::predFreq}.. }
\item{mean.change}{ Aggregate changes among alleles. }
\item{change.FUN}{ Function used the aggregate changes. }
\item{baseline.colour, future.colour, manual.colour.values}{ Colours to be used in the plots. } 
  
}


\value{
The function generates a ggplot that depicts changes between baseline and future/past allele frequencies of the populations.
}

\seealso{
\code{\link{shift.pie.ggplot}}, \code{\link{shift.moon.ggplot}}, \code{\link{shift.waffle.ggplot}}, \code{\link{shift.surf.ggplot}}
}

\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

# The data can be obtained via the count.model and freq.model calibrations.
# These procedures are not repeated here.
data(Poptri.freq.future)

ggdot1 <- shift.dot.ggplot(Poptri.freq.future)
ggdot1

# create an animation

\dontrun{

library(ggplot2)
library(gganimate)
library(gifski)

# The data is an interpolation and extrapolation between the baseline and future climate.
# For actual application, interpolate between climate data from available sources

data(Poptri.1985to2085)

ggdot.all <- ggplot(data=Poptri.1985to2085, group=Decade) +
  scale_y_continuous(limits=c(-0.1, 1.1),
                     breaks=c(0.0, 0.25, 0.5, 0.75, 1.0)) +
  geom_errorbar(aes(x=Pop, ymin=LCL, ymax=UCL),
                colour="grey30", width=0.8, show.legend=FALSE) +
  geom_segment(aes(x=Pop, y=Allele.freq, xend=Pop, yend=Freq.e2, colour=increasing),
               size=1.2) +  
  geom_point(aes(x=Pop, y=Allele.freq),
             colour="black", size=10, alpha=0.7) +                    
  geom_point(aes(x=Pop, y=Freq.e2),
             colour="dodgerblue3", size=10, alpha=0.7) +  
  coord_flip() +
  xlab(element_blank()) +
  ylab("Allele frequencies") +
  theme(panel.grid.minor = element_blank()) +
  labs(colour="Future change in allele frequencies") +
  scale_colour_manual(values=c("firebrick3", "chartreuse4"), 
                      labels=c("decreasing", "increasing")) +
  theme(axis.text.x=element_text(angle=90, vjust=0.5, size=10)) +
  theme(legend.position="top") +
  facet_grid( ~ Allele, scales="free")

ggdot.all

ggdot.anim <- ggdot.all + 
  transition_states(as.factor(Decade), transition_length = 10, state_length = 100) +
  labs(title = "Decade: {closest_state}s")

ggdot.anim2 <- animate(ggdot.anim, fps=5, width=1280, height=720)

getwd()
anim_save(filename="Allele shift animation.gif", animation=ggdot.anim2)

}

}




