# Internal functions for plots --------------------------------------------
# This file contains all the internal utility functions for many of the
# plots available in these package. We regret to say that these functions
# are currently undocumented :(.

col2rgb_alpha <- function(bgCol, alpha = 1) {
  if (alpha >= 0 && alpha <= 1) {
    alpha <- alpha * 255
  } else if (alpha < 0 || alpha > 255) {
    stop("Not a valid entry for alpha (transparency).")
  }

  apply(
    grDevices::col2rgb(bgCol, alpha = FALSE),
    2,
    function(tidx) {
      rgb(tidx[1], tidx[2], tidx[3], alpha = alpha, maxColorValue = 255)
    }
  )
}

par_reset <- function() {
  invisible(tryCatch({dev.off()}, error = function(e) { }))
}

get_ytop    <- function() { par()$usr[4] }

get_ybottom <- function() { par()$usr[3] }

par_edit    <- function(par, ...) {
  dots  <- list(...)
  for (i in seq_len(length(dots))) {
    if (!is.null(dots[[i]])) {
      par[i] <- dots[[i]]
    }
  }
  par
}
