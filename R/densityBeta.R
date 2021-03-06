#' Beta density (univariate, continuous, bounded space)
#'
#' @inherit Density
#' @param alpha Either a fixed value or a prior density for the first shape parameter.
#' @param beta  Either a fixed value or a prior density for the second shape parameter.
#' @family Density
#'
#' @examples
#' # With fixed values for the parameters
#' Beta(1, 1)
#'
#' # With priors for the parameters
#' Beta(
#'   alpha = Exponential(1), beta = Exponential(1)
#' )
Beta <- function(alpha = NULL, beta = NULL, ordered = NULL, equal = NULL, bounds = list(NULL, NULL),
                 trunc = list(NULL, NULL), k = NULL, r = NULL, param = NULL) {
  Density("Beta", ordered, equal, bounds, trunc, k, r, param, alpha = alpha, beta = beta)
}

#' @keywords internal
#' @inherit freeParameters
freeParameters.Beta <- function(x) {
  alphaStr <-
    if (is.Density(x$alpha)) {
      alphaBoundsStr <- make_bounds(x, "alpha")
      sprintf(
        "real%s alpha%s%s;",
        alphaBoundsStr, get_k(x, "alpha"), get_r(x, "alpha")
      )
    } else {
      ""
    }

  betaStr <-
    if (is.Density(x$beta)) {
      betaBoundsStr <- make_bounds(x, "beta")
      sprintf(
        "real%s beta%s%s;",
        betaBoundsStr, get_k(x, "beta"), get_r(x, "beta")
      )
    } else {
      ""
    }

  collapse(alphaStr, betaStr)
}

#' @keywords internal
#' @inherit fixedParameters
fixedParameters.Beta <- function(x) {
  alphaStr <-
    if (is.Density(x$alpha)) {
      ""
    } else {
      if (!check_scalar(x$alpha)) {
        stop("If fixed, alpha must be a scalar.")
      }

      sprintf(
        "real alpha%s%s = %s;",
        get_k(x, "alpha"), get_r(x, "alpha"), x$alpha
      )
    }

  betaStr <-
    if (is.Density(x$beta)) {
      ""
    } else {
      if (!check_scalar(x$beta)) {
        stop("If fixed, beta must be a scalar.")
      }

      sprintf(
        "real beta%s%s = %s;",
        get_k(x, "beta"), get_r(x, "beta"), x$beta
      )
    }

  collapse(alphaStr, betaStr)
}

#' @keywords internal
#' @inherit generated
generated.Beta <- function(x) {
  sprintf(
    "if(zpred[t] == %s) ypred[t][%s] = beta_rng(alpha%s%s, beta%s%s);",
    x$k, x$r,
    get_k(x, "alpha"), get_r(x, "alpha"),
    get_k(x, "beta"), get_r(x, "beta")
  )
}

#' @keywords internal
#' @inherit getParameterNames
getParameterNames.Beta <- function(x) {
  return(c("alpha", "beta"))
}

#' @keywords internal
#' @inherit logLike
logLike.Beta <- function(x) {
  sprintf(
    "loglike[%s][t] = beta_lpdf(y[t] | alpha%s%s, beta%s%s);",
    x$k,
    get_k(x, "alpha"), get_r(x, "alpha"),
    get_k(x, "beta"), get_r(x, "beta")
  )
}

#' @keywords internal
#' @inherit prior
prior.Beta <- function(x) {
  truncStr <- make_trunc(x, "")
  rStr     <- make_rsubindex(x)
  sprintf(
    "%s%s%s ~ beta(%s, %s) %s;",
    x$param,
    x$k, rStr,
    x$alpha, x$beta,
    truncStr
  )
}
