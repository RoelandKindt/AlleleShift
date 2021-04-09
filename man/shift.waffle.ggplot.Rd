\name{shift.waffle.ggplot}
\alias{shift.waffle.ggplot}
\alias{waffle.baker}

\title{Shifts of Allele Frequencies as Response to Climate Change}

\description{
The function shows changes in allele frequencies between the baseline and future/past climate.
}

\usage{

shift.waffle.ggplot(future.waffle,
	manual.colour.values = c("black", "grey", "firebrick3", "chartreuse4"),
	manual.colour.codes = c("A baseline ", "B", "A decreasing", "A increasing"))

waffle.baker(freq.in, sort.index = "Pop.index",
	mean.change = FALSE, change.FUN = stats::median)

}

\arguments{

\item{future.waffle}{ Result from \code{AlleleShift::waffle.baker}. }
\item{manual.colour.values}{ Colours to be used in the plot. }
\item{manual.colour.codes}{ Sequence for the manual colour values. }

\item{freq.in}{ Result from \code{AlleleShift::predFreq}. }
\item{sort.index}{ Sequence of the populations in the plot. }
\item{mean.change}{ Aggregate changes among alleles. }
\item{change.FUN}{ Function used the aggregate changes. }

}

\details{
Althought a package \code{ggwaffle} exists, I opted to bake my own waffles (possibly the Belgian in me.). As a separate row is created for each square/rectangle of the waffle, the resulting data is quite large. Hence trying to animate this is probably a bad idea (unless you want to make some real waffles while your computer is busy).
}


\value{
The function generates a ggplot that depicts changes between baseline and future/past allele frequencies of the populations.
}

\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

# The data can be obtained via the count.model and freq.model calibrations.
# These procedures are not repeated here.
data(Poptri.freq.baseline)
data(Poptri.freq.future)

Poptri.future.waffle <- waffle.baker(Poptri.freq.future,
                           sort.index="Latitude.index")

ggwaffle1 <- shift.waffle.ggplot(Poptri.future.waffle)
ggwaffle1

}




