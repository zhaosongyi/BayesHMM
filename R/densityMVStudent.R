#' Multivariate Student density (Multivariate, continuous, unbounded space)
#'
#' @inherit Density
#' @param mu    Either a fixed value or a prior density for the mean vector.
#' @param sigma Either a fixed value or a prior density for the covariance matrix.
#' @param nu    Either a fixed value or a prior density for the degree-of-freedom scalar parameter.
#'
#' @family Density
#'
#' @examples
#' # With fixed values for the parameters
#' MVStudent(
#'   mu    = c(0, 0),
#'   sigma = matrix(c(1, 0, 0, 1), 2, 2),
#'   nu    = 2
#' )
#'
#' # With priors for the parameters
#' MVStudent(
#'   mu    = MVGaussian(mu = c(0, 0), sigma = matrix(c(1, 0, 0, 1), 2, 2)),
#'   sigma = InverseWishart(nu = 5, sigma = matrix(c(1, 0, 0, 1), 2, 2)),
#'   nu    = GammaDensity(2, 0.1)
#' )
MVStudent <- function(mu = NULL, sigma  = NULL, nu = NULL, ordered = NULL, equal = NULL, bounds = list(NULL, NULL),
                      trunc  = list(NULL, NULL), k = NULL, r = NULL, param = NULL) {
  MultivariateDensity("MVStudent", ordered, equal, bounds, trunc, k, r, param, mu = mu, sigma = sigma, nu = nu)
}

#' @keywords internal
#' @inherit freeParameters
freeParameters.MVStudent <- function(x) {
  muStr <-
    if (is.Density(x$mu)) {
      sprintf(
        "%s[R] mu%s;",
        make_ordered(x$mu, "vector", "ordered"),
        get_k(x, "mu")
      )
    } else {
      ""
    }

  sigmaStr <-
    if (is.Density(x$sigma)) {
      sprintf(
        "cov_matrix[R] sigma%s;",
        get_k(x, "sigma")
      )
    } else {
      ""
    }

  nuStr <-
    if (is.Density(x$nu)) {
      nuBoundsStr <- make_bounds(x, "nu")
      sprintf(
        "real%s nu%s[1];", # Since the distribution is MV, we write all the parameters in matrix form.
        nuBoundsStr, get_k(x, "nu")   # nu, a scalar, thus become a row vector.
      )
    } else {
      ""
    }

  collapse(muStr, sigmaStr, nuStr)
}

#' @keywords internal
#' @inherit fixedParameters
fixedParameters.MVStudent <- function(x) {
  muStr <-
    if (is.Density(x$mu)) {
      ""
    } else {
      if (!check_vector(x$mu)) {
        stop(sprintf("If fixed, mu must be a vector of size R"))
      }

      sprintf(
        "vector[R] mu%s = %s';",
        get_k(x, "mu"), vector_to_stan(x$mu)
      )
    }

  sigmaStr <-
    if (is.Density(x$sigma)) {
      ""
    } else {
      if (!check_matrix(x$sigma)) {
        stop("If fixed, sigma must be a matrix of size RxR")
      }

      sprintf(
        "matrix[R, R] sigma%s = %s;",
        get_k(x, "sigma"), matrix_to_stan(x$sigma)
      )
    }

  nuStr <-
    if (is.Density(x$nu)) {
      ""
    } else {
      if (!check_scalar(x$nu)) {
        stop("If fixed, nu must be a scalar.")
      }

      sprintf(
        # If you wonder why we cast nu to float and make it a 1-d array,
        # see comment in freeParameters.MVStudent
        "real nu%s[1] = {%s};",
        get_k(x, "nu"), sprintf("%f", x$nu)
      )
    }

  collapse(muStr, sigmaStr, nuStr )
}

#' @keywords internal
#' @inherit generated
generated.MVStudent <- function(x) {
  # If you wonder why we cast nu to real, see comment in freeParameters.MVStudent
  sprintf(
    "if(zpred[t] == %s) ypred[t] = multi_student_t_rng(nu%s[1], mu%s, sigma%s)';",
    x$k, get_k(x, "nu"), get_k(x, "mu"), get_k(x, "sigma")
  )
}

#' @keywords internal
#' @inherit getParameterNames
getParameterNames.MVStudent <- function(x) {
  return(c("mu", "sigma", "nu"))
}

#' @keywords internal
#' @inherit logLike
logLike.MVStudent <- function(x) {
  # If you wonder why we cast nu to real, see comment in freeParameters.MVStudent
  sprintf(
    "loglike[%s][t] = multi_student_t_lpdf(y[t] | nu%s[1], mu%s, sigma%s);",
    x$k, get_k(x, "nu"), get_k(x, "mu"), get_k(x, "sigma")
  )
}

#' @keywords internal
#' @inherit prior
prior.MVStudent <- function(x) {
  stop("TO BE IMPLEMENTED.")
}
