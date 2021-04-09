\name{count.model}
\alias{count.model}
\alias{count.pred}
\alias{freq.model}
\alias{freq.pred}
\alias{freq.ggplot}

\title{Calibration and Prediction Functions for Changes in Allele Frequencies}

\description{
The functions implement a two-step calibration and prediction process for allele frequencies, whereby the second calibration step uses the predictions of the first step.
}

\usage{

count.model(genpop.data, env.data, permutations = 99, 
    ordistep = FALSE, cca.model = FALSE)

count.pred(count.model, env.data)

freq.model(count.predicted)

freq.pred(freq.model, count.predicted)

freq.ggplot(freq.predicted, plot.best = TRUE, threshold = 0.50,
	colour.Pop = TRUE, manual.colour.values = NULL,
	xlim = c(0.0, 1.0), ylim = c(0.0, 1.0))

}

\arguments{

    \item{genpop.data}{ Data in the format of \code{\link[adegenet]{genpop}}. }
    \item{env.data}{ Descriptors of (bio-)climatic conditions for the populations, either for the baseline climate (to check calibrations) or future/past climates. It is expected that these are in the same sequence as the populations in the \code{genpop.data}.  }
    \item{permutations}{ Number of permutations as in \code{\link[vegan]{anova.cca}}. }
    \item{ordistep}{ Check the results of  {\link[vegan]{ordistep}}. } 
    \item{cca.model}{ Fit a CCA model with the minor allele frequency as in Blumstein et al. 2020. }
  
    \item{count.model}{ Model fitted by \code{count.model}. }

    \item{count.predicted}{ Predictions made by \code{count.pred}, expected to be predicted for the baseline climate as a second step in the calibration process. }

    \item{freq.model}{ Model fitted by \code{freq.model}. }

    \item{freq.predicted}{ Allele frequencies predicted by \code{freq.pred}. }
    \item{plot.best}{ Plot the models with highest R2 (\code{TRUE}) or lowest R2 values (\code{FALSE}). }
    \item{threshold}{ Threshold used to distinguish between the best and worst model. }
    \item{colour.Pop}{ Colour populations differently (\code{TRUE}), or alleles differently (\code{FALSE}) }
    \item{manual.colour.values}{ Manual specifications for colour values }
    \item{xlim}{ limits of the x-axis }
    \item{ylim}{ limits of the y-axis }

}

\details{
These functions allow for an almost completely alternative workflow of predicting shifts in allele frequencies under climate change than the protocol developed by Blumstein et al. 2020. The methodology available here calibrates and predicts changes in allele frequencies via redundancy analysis (Blumstein et al. use canonical correspondence analysis) that were calibrated from allele counts (Blumstein et al. use allele frequencies) for all alleles (Blumstein et al. only calibrate the minor alleles) in a two-step calibration process (the second step via freq.model and freq.predict to ensure that predicted alleles are in the range of 0-1 is not included in protocol developed by Blumstein et al.). Other key differences in the methodology are that explanatory variables are expected to be bioclimatic variables (and not principal components as in Blumstein et al.) and that the input data is expected to be in the \code{\link[adegenet]{genpop}} format. Although a method to reduce the number of explanatory variables via \code{\link[vegan]{ordistep}} is shown, I advise against reducing the explanatory variables as this likely will reduce the explanatory power of the models, whereas explanatory power is the major objective of calibrating these functions. Motivations for the differences in methodologies of Blumstein et al. and the ones available in AlleleShift are explained by Kindt 2021. 

Confidence intervals are calculated via \code{\link[stats]{qt}} with p=0.95 and df=np (number of populations), although the GAM is fitted only once for all the alleles and all the populations (that was my choice to reduce overfitting the baseline data). 

The 'darkolivegreen4'-coloured reference lines shown via \code{freq.ggplot} correspond to a 1:1 relationship (full line) and 1:0.95 and 1:1.05 relationships (dashed lines).

}

\value{
The functions enable calibration and prediction of allele frequencies.
}

\references{
Blumstein et al. 2020. Protocol for Projecting Allele Frequency Change under Future Climate Change at Adaptive-Associated Loci. \doi{10.1016/j.xpro.2020.100061}

Kindt R. 2021. AlleleShift: An R package to predict and visualize population-level changes in allele frequencies in response to climate change. \doi{10.1101/2021.01.15.426775}
}

\seealso{
\code{\link{VIF.subset}}, \code{\link{population.shift}}, \code{\link{amova.rda}}
}


\author{Roeland Kindt (World Agroforestry, CIFOR-ICRAF)}

\examples{

\donttest{

# A typical work flow would consist of:

# 1. Reduce the number of explanatory variables

data(Poptri.baseline.env)
data(Poptri.future.env)

VIF.select <- VIF.subset(Poptri.baseline.env, 
                         keep=c("MAT", "CMI"), 
                         cor.plot=TRUE)  

VIF.select$VIF$vars.included

baseline.env <- Poptri.baseline.env[, VIF.select$VIF$vars.included] 
summary(baseline.env)

future.env <- Poptri.future.env[, VIF.select$VIF$vars.included] 


# 2. Create the genpop object

data(Poptri.genind)
Poptri.genpop <- adegenet::genind2genpop(Poptri.genind)

# Get to know the populations and the alleles
poppr::poppr(Poptri.genind)
adegenet::makefreq(Poptri.genpop)

# 3. Calibrate the models

# Note that the ordistep procedure is not needed
# CCA model only to compare results with those by Blumstein et al. 2020 
Poptri.count.model <- count.model(Poptri.genpop, 
                                  env.data=baseline.env, 
				  ordistep=TRUE, 
                                  cca.model=TRUE)

Poptri.pred.baseline <- count.pred(Poptri.count.model, env.data=baseline.env)
head(Poptri.pred.baseline)

Poptri.freq.model <- freq.model(Poptri.pred.baseline)
Poptri.freq.baseline <- freq.pred(Poptri.freq.model,
                                  count.predicted=Poptri.pred.baseline)

head(Poptri.freq.baseline)

# 4. Check how well the models predict baseline allele frequencies

# Populations are split in those with R2 > 0.50 and those with R2 < 0.50
# Better populations
plotA1 <- freq.ggplot(Poptri.freq.baseline, 
            plot.best=TRUE,
            ylim=c(0.0, 0.8))
plotA1

# Populations with low R2
manual.colour.values1 <- ggsci::pal_npg()(5)

plotB1 <- freq.ggplot(Poptri.freq.baseline, 
            plot.best=FALSE, 
            manual.colour.values=manual.colour.values1,
            xlim=c(0, 0.5),
            ylim=c(0, 0.25))
plotB1

# Colouring by alleles

plotA2 <- freq.ggplot(Poptri.freq.baseline, 
            colour.Pop=FALSE,
            plot.best=TRUE,
            ylim=c(0.0, 0.8),
            manual.colour.values=manual.colour.values1)

plotA2

plotB2 <- freq.ggplot(Poptri.freq.baseline, 
            colour.Pop=FALSE,
            plot.best=FALSE, 
            manual.colour.values=manual.colour.values1,
            xlim=c(0, 0.5),
            ylim=c(0, 0.25))

plotB2

# 5. Predict future allele frequencies

Poptri.pred.future <- count.pred(Poptri.count.model, env.data=future.env)
head(Poptri.pred.future)

Poptri.freq.future <- freq.pred(Poptri.freq.model,
                                count.predicted=Poptri.pred.future)

# The key results are variables 'Allele.freq' representing the baseline allele frequencies
# and variables 'Freq.e2', the predicted frequency for the future/ past climate.
# Variable 'Freq.e1' is the predicted allele frequency in step 1

head(Poptri.freq.future)

# 5. Visualize the changes
# See functions shift.dot.ggplot, shift.pie.ggplot, shift.moon.gpplot, 
# shift.waffle.ggplot and shift.surf.ggplot

}
}




