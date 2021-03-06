% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conjoint.R
\name{store.conjoint.predict.by}
\alias{store.conjoint.predict.by}
\title{Store method for the Multivariate > Conjoint > Predict}
\usage{
\method{store}{conjoint.predict.by}(object, name = "predict_by",
  envir = parent.frame(), ...)
}
\arguments{
\item{object}{Return value from predict.conjoint}

\item{name}{Name of the dataset to store}

\item{envir}{Environment to assign 'new' dataset (optional). Used when an r_data list is not available}

\item{...}{further arguments passed to or from other methods}
}
\description{
Store method for the Multivariate > Conjoint > Predict
}
\details{
Store data frame with predictions in Radiant r_data list if available
}
