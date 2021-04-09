\name{VIF.subset}
\alias{VIF.subset}

\title{Reduce the Climate Data based on Variance Inflation Factor Analysis.}

\description{
Through Variance Inflation Factor (VIF) analysis, a subset of variables is indentified where all variables have VIF below a predefined threshold.
}

\usage{

VIF.subset(data, VIF.max, keep=NULL, silent=FALSE, cor.plot=TRUE)

}

\arguments{

\item{data}{ (Bio)-Climatic or environmental descriptors of the populations }
\item{VIF.max}{ Maximum Variance Inflation Factor as in \code{\link[BiodiversityR]{ensemble.VIF.dataframe}} that is used internally. }
\item{keep}{ Variables to keep as in as in \code{\link[BiodiversityR]{ensemble.VIF.dataframe}}. } 
\item{silent}{ Limit the verbose output as in \code{\link[BiodiversityR]{ensemble.VIF.dataframe}}. } 
\item{cor.plot}{ Generate a correlation matrix for the final subset via \code{\link[GGally]{ggcorr}}. } 
  
}

\value{
The function returns information on a subset of variables where VIF is below a pre-defined threshold.
}


\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

\donttest{

data(Poptri.baseline.env)

# error as many variables are highly correlated
# VIF.subset(Poptri.baseline.env)

VIF.subset(Poptri.baseline.env, keep=c("MAT", "CMI"), cor.plot=TRUE)
}
}




