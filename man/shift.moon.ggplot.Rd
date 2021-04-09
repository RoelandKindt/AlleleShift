\name{shift.moon.ggplot}
\alias{shift.moon.ggplot}
\alias{moon.waxer}

\title{Shifts of Allele Frequencies as Response to Climate Change}

\description{
The function shows changes in allele frequencies between the baseline and future/past climate.
}

\usage{

shift.moon.ggplot(baseline.moon, future.moon,
	manual.colour.values = c("white", "grey", "firebrick3", "chartreuse4"),
	manual.colour.codes = c("A baseline ", "B", "A decreasing", "A increasing"))

moon.waxer(freq.in, sort.index= "Pop.index",
	mean.change = FALSE, change.FUN = stats::median,
	freq.focus = "Allele.freq", 
	ypos = 0, right = TRUE)

}

\arguments{

\item{baseline.moon, future.moon}{ Result from \code{AlleleShift::moon.waxer}. }
\item{manual.colour.values}{ Colours to be used in the plot. }
\item{manual.colour.codes}{ Sequence for the manual colour values. }

\item{freq.in}{ Result from \code{AlleleShift::predFreq}. }
\item{sort.index}{ Sequence of the populations in the plot.}
\item{mean.change}{ Aggregate changes among alleles. }
\item{change.FUN}{ Function used the aggregate changes. }
\item{freq.focus}{ Allele frequency for which to calculate statistics, either 'Allele.freq' or 'Freq.e2'. }
\item{ypos, right}{ Arguments used for plotting, mainly as in \code{\link[gggibbous]{geom_moon}} } 
  
}


\value{
The function generates a ggplot that depicts changes between baseline and future/past allele frequencies of the populations.
}

\seealso{
\code{\link{shift.dot.ggplot}}, \code{\link{shift.pie.ggplot}}, \code{\link{shift.waffle.ggplot}}, \code{\link{shift.surf.ggplot}}
}


\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

# The data can be obtained via the count.model and freq.model calibrations.
# These procedures are not repeated here.
data(Poptri.freq.baseline)
data(Poptri.freq.future)

Poptri.baseline.moon <- moon.waxer(Poptri.freq.baseline,
                                   sort.index="Latitude.index")

Poptri.future.moon <- moon.waxer(Poptri.freq.future, 
                                 sort.index="Latitude.index",
                                 freq.focus="Freq.e2",
                                ypos=1)

ggmoon1 <- shift.moon.ggplot(Poptri.baseline.moon, 
                             Poptri.future.moon)
ggmoon1

}




