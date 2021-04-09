\name{shift.surf.ggplot}
\alias{shift.surf.ggplot}

\title{Shifts of Allele Frequencies as Response to Climate Change}

\description{
The function shows changes in allele frequencies between the baseline and future/past climate.
}

\usage{

shift.surf.ggplot(freq.future,
	Allele.focus=unique(freq.future$Allele)[1],
	freq.focus="Allele.freq",
	xcoord="LON", ycoord="LAT",
	mean.change = FALSE, change.FUN = stats::median,
	manual.colour.values = c("firebrick3", "chartreuse4"),
	...)

}

\arguments{

\item{freq.future}{ Result from \code{AlleleShift::predFreq}. }
\item{freq.focus}{ Selection of the Allele.}
\item{Allele.focus}{ Selection of the frequency.}
\item{xcoord, ycoord}{ Geographical coordinates of the populations.}
\item{mean.change}{ Aggregate changes among alleles. }
\item{change.FUN}{ Function used the aggregate changes. }
\item{manual.colour.values}{Colours to be used in the plot. }
\item{...}{ Options for \code{\link[vegan]{ordisurf}}. }
}

\details{
Populations are plotted in geographical space via ordination plotting methods, which is suitable as fixed coordinate systems are recommended both in ordination diagrams and maps. See Kindt (2020) for alternative methods of generating ordination diagrams via vegan, BiodiversityR and ggplot2.
}


\value{
The function generates a ggplot that depicts changes between baseline and future/past allele frequencies of the populations.
}


\references{
Kindt R. 2020. Ordination graphs with vegan, BiodiversityR and ggplot2. \url{https://rpubs.com/Roeland-KINDT}
}

\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\seealso{
\code{\link{shift.dot.ggplot}}, \code{\link{shift.pie.ggplot}}, \code{\link{shift.moon.ggplot}}, \code{\link{shift.waffle.ggplot}}
}


\examples{

# The data can be obtained via the count.model and freq.model calibrations.
# These procedures are not repeated here.
data(Poptri.freq.baseline)
data(Poptri.freq.future)

# Plots for the first allele
# Symbols and colours indicate future change (green, ^ = future increase)
# Symbol size reflects the frequency in the climate shown

# Baseline climate
plotA <- shift.surf.ggplot(Poptri.freq.future,
                  xcoord="Long", ycoord="Lat",
                  Allele.focus=unique(Poptri.freq.future$Allele)[1], 
                  freq.focus="Allele.freq")
plotA

# Future/past climate
plotB <- shift.surf.ggplot(Poptri.freq.future,
                  xcoord="Long", ycoord="Lat",
                  Allele.focus=unique(Poptri.freq.future$Allele)[1], 
                  freq.focus="Freq.e2")
plotB

# Plots for the fifth allele

# Baseline climate
plotC <- shift.surf.ggplot(Poptri.freq.future,
                  xcoord="Long", ycoord="Lat",
                  Allele.focus=unique(Poptri.freq.future$Allele)[5], 
                  freq.focus="Allele.freq")
plotC

# Future climate
plotD <- shift.surf.ggplot(Poptri.freq.future,
                  xcoord="Long", ycoord="Lat",
                  Allele.focus=unique(Poptri.freq.future$Allele)[5], 
                  freq.focus="Freq.e2")
plotD

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

Poptri.1985to2085$xcoord <- Poptri.1985to2085$Long
Poptri.1985to2085$ycoord <- Poptri.1985to2085$Lat

alleles <- sort(unique(as.character(Poptri.1985to2085$Allele)))
future.data <- Poptri.1985to2085[Poptri.1985to2085$Allele == alleles[1], ]

decades <- sort(unique(future.data$Decade))

for (d in 1:length(decades)) {
  decade.focal <- decades[d]
  decade.data <- future.data[future.data$Decade == decade.focal, ]
  plotLONLAT <- vegan::ordiplot(decade.data[, c("xcoord", "ycoord")]) 
  surfAllele <- BiodiversityR::ordisurfgrid.long(vegan::ordisurf(plotLONLAT, y=decade.data$Freq.e2))
  decade.surf <- cbind(Decade=rep(decade.focal, nrow(surfAllele)), surfAllele)  
  if (d == 1) {
    future.surfs <- decade.surf
  }else{
    future.surfs <- rbind(future.surfs, decade.surf)
  }
}

# The function above will not be able to predict far into the future.
# The results obtained (future.surfs) can still be used for plotting.

ggsurf.all <- ggplot(data=future.surfs, group=Decade) +
  geom_contour_filled(aes(x=x, y=y, z=z),
                      breaks=seq(from=0.0, to=1.05, by=0.05)) +
  geom_point(data=subset(future.data, Decade==Decade),
             aes(x=xcoord, y=ycoord, size=Freq.e2, shape=increasing),
             colour="red", alpha=0.8, stroke=1.5, show.legend=FALSE) +
  xlab(element_blank()) +
  ylab(element_blank()) +
  labs(fill=alleles[1]) +
  scale_fill_viridis_d() +
  scale_colour_manual(values=c("firebrick3", "chartreuse4"),
                      guide=FALSE) +
  scale_size_area(max_size=6) +
  scale_shape_manual(values=c(6, 2)) +
  theme(panel.grid = element_blank()) +
  theme(axis.text= element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(legend.title = element_text(size=9)) +
  theme(legend.text = element_text(size=8)) +
  coord_fixed()

ggsurf.all
 
ggsurf.anim <- ggsurf.all + 
  transition_states(as.factor(Decade), transition_length = 10, state_length = 100) +
  labs(title = "Decade: {closest_state}s")

ggsurf.anim2 <- animate(ggsurf.anim, fps=5, width=1280, height=720)

getwd()
anim_save(filename="Allele shift surf animation.gif", animation=ggsurf.anim2)

}

}




