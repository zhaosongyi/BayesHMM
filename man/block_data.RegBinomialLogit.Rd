% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/densityRegBinomialLogit.R
\name{block_data.RegBinomialLogit}
\alias{block_data.RegBinomialLogit}
\title{Write the data block of the Stan code.}
\usage{
\method{block_data}{RegBinomialLogit}(x, noLogLike)
}
\arguments{
\item{x}{A \code{\link{Density}} or a \code{\link{Specification}} object.}

\item{noLogLike}{A logical stating whether the log-likelihood should be excluded from the program. If TRUE, the Stan code will draw samples from the prior predictive density. If FALSE, the Stan code will draw samples from the posterior predictive density.}
}
\value{
A character string with the Stan code.
}
\description{
Write the data block of the Stan code.
}
\keyword{internal}
