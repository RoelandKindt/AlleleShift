\name{population.shift}
\alias{population.shift}

\title{Shifts of Populations in Environmental Space as Response to Climate Change}

\description{
The function plots the locations of each population in baseline and future climates. Arrows indicate the shifts in positions of the populations.
}

\usage{

population.shift(baseline.env.data, future.env.data,
	option=c("PCA", "RDA"), vector.multiply=1)

}

\arguments{

\item{baseline.env.data}{ Baseline (bio-)climatic conditions for the populations. }
\item{future.env.data}{ Changed (bio-)climatic conditions in future/past for the populations. }
\item{option}{ Should an explanatory variable corresponding to the climate period be used by \code{\link[vegan]{rda}}. }
\item{vector.multiply}{ Multiplier for vector scores in the ordination diagrams. } 
  
}

\details{
See Kindt (2020) for alternative methods of generating ordination diagrams via vegan, BiodiversityR and ggplot2.
}


\value{
The function generates an ordination diagram that depicts changes between baseline and future/past conditions for the populations.
}

\references{
Kindt R. 2020. Ordination graphs with vegan, BiodiversityR and ggplot2. \url{https://rpubs.com/Roeland-KINDT}
}

\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

\dontrun{

data(Poptri.baseline.env)
data(Poptri.future.env)

VIF.select <- VIF.subset(Poptri.baseline.env, 
                         keep=c("MAT", "CMI"), 
                         cor.plot=FALSE)  

VIF.select$vars.included

baseline.env <- Poptri.baseline.env[, VIF.select$vars.included] 
future.env <- Poptri.future.env[, VIF.select$vars.included] 

plotA <- population.shift(baseline.env, 
                 future.env,
                 option="PCA")
plotA

plotB <- population.shift(baseline.env, 
                 future.env,
                 option="RDA")
plotB

}

}




