# Following methods work with fit objects only ----------------------------

#' Return the name of the model parameters.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @param observation An optional logical scalar indicating whether the names of the observation model parameters should be included. Defaults to TRUE.
#' @param initial An optional logical scalar indicating whether the names of the initial model parameters should be included. Defaults to TRUE.
#' @param transition An optional logical scalar indicating whether the names of the transition model parameters should be included. Defaults to TRUE.
#' @return A character string with the selected model parameter names.
select_parameters <- function(fit, observation = TRUE,
                              initial = TRUE, transition = TRUE) {
  spec            <- extract_spec(fit)
  paramNames      <- ""

  if (observation) {
    paramNames    <- c(paramNames, densityApply(spec$observation$density, getParameterNames))
  }

  if (initial) {
    if (is.TVInitial(spec)) {
      paramNames  <- c(paramNames, densityApply(spec$initial$density, getParameterNames))
    } else {
      paramNames  <- c(paramNames, densityCollect(spec$initial$density, `[[`, "param"))
    }
  }

  if (transition) {
    if (is.TVTransition(spec)) {
      paramNames  <- c(paramNames, densityApply(spec$transition$density, getParameterNames))
    } else {
      paramNames  <- c(paramNames, densityCollect(spec$transition$density, `[[`, "param"))
    }
  }

  paramPatterns   <- glob2rx(sprintf("%s*", unique(paramNames)[-1]))
  fitNames        <- extract_parameter_names(fit)
  paramInd        <- Reduce(
    `|`,
    lapply(paramPatterns, function(pattern) {
      grepl(pattern, fitNames)
    })
  )

  fitNames[paramInd]
}

#' Return the name of the observation model parameters.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @return A character vector with the names of the observation model parameters.
#' @seealso \code{\link{select_parameters}}.
select_obs_parameters <- function(fit) {
  select_parameters(fit, TRUE, FALSE, FALSE)
}

#' Return the name of the initial model parameters.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @return A character vector with the names of the initial model parameters.
#' @seealso See \code{\link{select_parameters}}.
select_initial_parameters <- function(fit) {
  select_parameters(fit, FALSE, TRUE, FALSE)
}

#' Return the name of the transition model parameters.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @return A character vector with the names of the transition model parameters.
#' @seealso \code{\link{select_parameters}}.
select_transition_parameters <- function(fit) {
  select_parameters(fit, FALSE, FALSE, TRUE)
}

#' Return the name of all model parameters.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @return A character vector with the names of all model parameters.
#' @seealso \code{\link{select_parameters}}.
select_all_parameters <- function(fit) {
  select_parameters(fit, TRUE, TRUE, TRUE)
}

#' Return the name of the parameters matching the pattern.
#'
#' @keywords internal
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @param pars Regular expressions against which parameter names should be matched.
#' @return A character vector with the names of matching model parameters.
match_parameter_names <- function(fit, pars) {
  parNames <- select_parameters(fit)
  ind      <- do.call(c, lapply(unique(pars), function(par) {
    grep(
      pattern = glob2rx(sprintf("%s*", par)),
      x       = parNames
    )})
  )

  parNames[ind]
}

#' Extract quantities from a model fitted with BayesHMM.
#'
#' The extract_* family of methods returns elements from a fit object (including fixed and estimated quantities, as well as internal elements of the fit object).
#'
#' The extract_* family is the safest way to access the generated samples (filtered probability \emph{alpha}, smoothed probability \emph{gamma}, most likely hidden path \emph{zstar}, observation samples from the posterior predictive density \emph{ypred}, hidden path samples from the posterior predictive density \emph{zpred}, simulated observations \emph{ysim}), the fixed pre-specified quantities (observations \emph{y}, time series length \emph{T}, number of hidden states \emph{K}, dimension of the observation vector \emph{R}), Markov-chain Monte Carlo specific information (convergence and posterior predictive diagnostics \emph{diagnostics}, number of chains \emph{n_chains}, total iterations \emph{n_iterations}, warm-up iterations \emph{n_warmup}, thinning \emph{n_thin}, sample size \emph{sample_size}), and other internal elements stored in a fit object (\code{\link{Specification}} object \emph{spec}, dataset in list format \emph{data}, date \emph{date}, time elapsed for fitting \emph{time}, seed \emph{seed}, path to the underlying Stan file \emph{filename}). Except for MCMC-specific functions, these all work interchangeably with both Markov-chain Monte Carlo samples returned by \code{\link{draw_samples}} and maximum a posteriori estimates returned by \code{\link{optimizing}}.
#'
#' @name extract
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @param reduce A function to be applied to all the samples generated by one chain for each parameters (i.e. "within chain"). Useful if only one or more summary measures of the generated samples is needed (e.g. the median of the generated sample). The function may return one of more elements. In the former case, the dimension is dropped in the returned object (read the \emph{Value} section below). Note that the user needs to supply a function as an argument, and not a character string with the name of the function.
#' @param combine A function applied to all the extracted quantities as an ensemble. In other words, instead of returning a named list where each element is one quantity, it returns the value returned by the function applied to the whole list (\code{\link{do.call}}). Useful when all the elements of the list have the same dimension, possibly because it is used in conjunction with the \emph{chain} and \emph{reduce} arguments.
#' @param chain Either "all" or any integer number between 1 and the number of chains M.
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{extract}} if the object \emph{fit} was returned by \code{\link{fit}} or \code{\link{draw_samples}}.
#' @family extract
#' @seealso The arguments \emph{reduce}, \emph{combine}, and \emph{chain} are very convenient tools to minimize the amount of data management in your code. See \code{\link{extract_quantity}} for an in-depth explanation on how these work.
NULL

#' Extract the estimates of the model parameters (observation, transition, and initial models).
#'
#' @param fit An object returned by either \code{\link{draw_samples}} or \code{\link{optimizing}}.
#' @param observation A boolean indicating whether the observation model parameters should be returned.
#' @param initial A boolean indicating whether the initial model parameters should be returned.
#' @param transition A boolean indicating whether the transition model parameters should be returned.
#' @param ... Arguments to be passed to rstan's \code{\link[rstan]{extract}} if the object \emph{fit} was returned by \code{\link{fit}} or \code{\link{draw_samples}}.
#' @return A named list with as many elements as model parameters. Each element is a numeric array with dimensions [N, M, ...]: number of iterations \emph{N}, number of chains \emph{M}, and one or more dimensions related to the characteristics of the parameter. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a numeric array with dimensions [N, ...]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, ...]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a three-dimensional numeric array [M, ...].
#' @family extract
extract_parameters <- function(fit, observation = TRUE,
                               initial = TRUE, transition = TRUE, ...) {
  pars <- select_parameters(fit, observation, initial, transition)
  sapply(pars, function(p) { extract_quantity(fit, p, ...) })
}

#' Extract the estimates of the observation model parameters.
#'
#' @inherit extract_parameters
#' @inheritParams extract
#' @family extract
extract_obs_parameters <- function(fit, ...) {
  extract_quantity(fit, pars = select_obs_parameters(fit), ...)
}

#' Extract the estimates of the filtered probability (alpha).
#'
#' @inheritParams extract
#' @return A numeric array with four dimensions [N, M, K, T]: number of iterations \emph{N}, number of chains \emph{M}, number of hidden states \emph{K}, length of the time series {T}. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a three-dimensional numeric array [N, K, T]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, K, T]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a three-dimensional numeric array [M, K, T].
#' @family extract
extract_alpha <- function(fit, reduce = NULL, combine = NULL, chain = "all", ...) {
  extract_quantity(fit, "alpha", reduce, combine, chain, ...)[[1]]
}

#' Extract the estimates of the smoothed probability (gamma).
#'
#' @inherit extract_alpha
#' @family extract
extract_gamma <- function(fit, reduce = NULL, combine = NULL, chain = "all", ...) {
  extract_quantity(fit, "gamma", reduce, combine, chain, ...)[[1]]
}

#' Extract the estimates of the most likely hidden state (zstar).
#'
#' @inherit extract_alpha
#' @family extract
extract_zstar <- function(fit, reduce = NULL, combine = NULL, chain = "all", ...) {
  extract_quantity(fit, "zstar", reduce, combine, chain, ...)[[1]]
}

#' Extract the sample of the observation variable drawn from the posterior predictive density (ypred).
#'
#' @inherit extract_alpha
#' @return A numeric array with four dimensions [N, M, T, R]: number of iterations \emph{N}, number of chains \emph{M}, length of the time series {T}, the dimension of the observation vector \emph{R}. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a three-dimensional numeric array [N, T, R]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, T, R]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a three-dimensional numeric array [M, T, R].
#'
#' @family extract
extract_ypred <- function(fit, reduce = NULL, combine = NULL, chain = "all", ...) {
  extract_quantity(fit, "ypred", reduce, combine, chain, ...)[[1]]
}

#' Extract the simulated sample of the observation variable (ysim).
#'
#' If the \emph{fit} object was created via the \code{\link{sim}} method, this function returns a sample of the observation variable from the prior predictive densitiy (i.e. using random values of the parameters). If a dataset was provided when fitting the model instead, the sample is simulated from the posterior predictive density. In the latter case, calling either \code{\link{extract_ysim}} and \code{\link{extract_ypred}} are equivalent.
#'
#' @param n (optional) An integer number indicating the number of the iteration that should be returned.
#' @inherit extract_ypred
#' @family extract
extract_ysim  <- function(fit, n = NULL, reduce = NULL, combine = NULL, chain = "all", ...) {
  ysim <- extract_quantity(fit, "ypred", reduce, combine, chain, ...)[[1]]

  if (is.null(n))
    return(ysim)

  out      <- ysim[slice.index(ysim, 1) == n]
  dim(out) <- dim(ysim)[-1]
  out
}

#' Extract the simulated sample of the state variable (zsim).
#'
#' If the \emph{fit} object was created via the \code{\link{sim}} method, this function returns a sample of the state variable from the prior predictive densitiy (i.e. using random values of the parameters). If a dataset was provided when fitting the model instead, the sample is simulated from the posterior predictive density. In the latter case, calling either \code{\link{extract_zsim}} and \code{\link{extract_zpred}} are equivalent.
#'
#' @param n (optional) An integer number indicating the number of the iteration that should be returned.
#' @inherit extract_zpred
#' @family extract
extract_zsim  <- function(fit, n = NULL, reduce = NULL, combine = NULL, chain = "all", ...) {
  zsim <- extract_quantity(fit, "zpred", reduce, combine, chain, ...)[[1]]

  if (is.null(n))
    return(zsim)

  out      <- zsim[slice.index(zsim, 1) == n]
  dim(out) <- dim(zsim)[-1]
  out
}

#' Extract the sample of the hidden state path drawn from the posterior predictive density (zpred).
#'
#' @inherit extract_alpha
#' @return A numeric array with three dimensions [N, M, T]: number of iterations \emph{N}, number of chains \emph{M}, length of the time series {T}, the dimension of the observation vector \emph{R}. If the argument \emph{chain} was set, the chain dimension is dropped and the function returns a two-dimensional numeric array [N, T]. If the argument \emph{reduce} was set to a function returning a vector of size \emph{n}, the returned array has dimension [n, M, T]. When \emph{n} is simply one (e.g. \code{\link{median}}), the number-of-iterations dimension is dropped and the function returns a two-dimensional numeric array [M, T].
#'
#' @family extract
extract_zpred <- function(fit, reduce = NULL, combine = NULL, chain = "all", ...) {
  extract_quantity(fit, "zpred", reduce, combine, chain, ...)[[1]]
}

#' Extract the dataset used to fit the model.
#'
#' @inherit extract
#' @return A named list with four elements: a numeric value with the number of hidden states \emph{K}, a numeric value with the dimension of the observation vector \emph{R}, a numeric value with the length of the time series {T}, the observation matrix \emph{y} with named dimensions [\emph{T}, \emph{R}].
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_data <- function(fit) {
  attr(fit, "data")
}

#' Extract the obsevation matrix used to fit the model \emph{y}
#'
#' @inherit extract
#' @return A numeric matrix with named dimensions [\emph{T}, \emph{R}].
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_y <- function(fit) {
  extract_data(fit)$y
}

#' Extract the length of the time series \emph{T}.
#'
#' @inherit extract
#' @return An integer with the length of the time series \emph{T}.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_T <- function(fit) {
  extract_data(fit)$T
}

# Following methods work with any object ----------------------------------

#' Extract the number of hidden states \emph{K}.
#' @param object An object returned by \code{\link{specify}}, \code{\link{hmm}}, \code{\link{compile}}, \code{\link{draw_samples}}, \code{\link{fit}} or \code{\link{optimizing}}.
#' @inherit extract
#' @return An integer with the number of hidden states \emph{K}.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_K <- function(object) {
  dataK <- extract_data(object)$K

  if (is.null(dataK))
    return(extract_spec(object)$K)

  dataK
}

#' Extract the dimension of the observation vector \emph{R}.
#'
#' @inherit extract
#' @inherit extract_K
#' @return An integer with the dimension of the observation vector \emph{R}.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_R <- function(object) {
  dataR <- extract_data(object)$R

  if (is.null(dataR))
    return(extract_spec(object)$observation$R)

  dataR
}

#' Extract the \code{\link{Specification}} object used to object the model.
#'
#' @inherit extract
#' @inherit extract_K
#' @return A \code{\link{Specification}} object.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @family extract
extract_spec <- function(object) {
  if (is.Specification(object))
    return(object)

  attr(object, "spec")
}

#' Extract the path to file with the underlying Stan code.
#'
#' @inherit extract
#' @inherit extract_K
#' @return A character string with the path to file with the underlying Stan code.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @seealso \code{\link{browse_model}} for viewing the code using your IDE.
#' @family extract
extract_filename <- function(object) {
  attr(object, "filename")
}

#' Extract the underlying Stan code.
#'
#' @inherit extract
#' @inherit extract_K
#' @return A character string with the underlying Stan code.
#' @note This function does not allow the arguments \emph{combine}, \emph{reduce}, and \emph{chain}.
#' @seealso \code{\link{browse_model}} for viewing the code using your IDE.
#' @family extract
extract_model <- function(object) {
  attr(object, "stanCode")
}

# browse_model ------------------------------------------------------------
#' Load the underlying Stan code into an IDE or browser.
#'
#' The behavior is platform dependent.
#'
#' @param object An object returned by \code{\link{specify}}, \code{\link{hmm}}, \code{\link{compile}}, \code{\link{draw_samples}}, \code{\link{fit}} or \code{\link{optimizing}}.
#' @param ... (optional) Arguments to be passed to \code{\link{browseURL}} (namely \emph{browser} and \emph{encodeIfNeeded}).
#' @return No return value.
#' @seealso \code{\link{browseURL}}.
browse_model <- function(object, ...) {
  UseMethod("browse_model", object)
}

#' @keywords internal
#' @inherit browse_model
browse_model.Specification <- function(object, ...) {
  filename <- write_model(
    spec      = object,
    noLogLike = FALSE,
    writeDir  = tempdir()
  )

  browseURL(filename)
}

#' @keywords internal
#' @inherit browse_model
browse_model.stanmodel     <- function(object, ...) {
  filename <- extract_filename(object)

  if (!file.exists(filename)) {
    string    <- extract_model(object)

    if (is.null(string))
      return(
        browse_model(extract_spec(object), ...)
      )

    filename <- tempfile()
    fileConn <- file(filename)
    writeLines(string, con = fileConn)
    close(fileConn)
  }

  browseURL(filename)
}

#' @keywords internal
#' @inherit browse_model
browse_model.stanfit      <- browse_model.stanmodel

#' @keywords internal
#' @inherit browse_model
browse_model.Optimization <- browse_model.stanmodel
