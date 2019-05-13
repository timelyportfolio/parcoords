# this code is very strongly based off of RStudio's leaflet package
#   https://github.com/rstudio/leaflet/blob/master/R/utils.R in
#   an attempt to establish some consistency around the htmlwidget
#   proxy mechanism for use with Shiny

# Given a remote operation and a parcoords proxy, execute. If code was
# not provided for the appropriate mode, an error will be raised.
invokeRemote <- function(pc, method, args = list()) {
  if (!inherits(pc, "parcoords_proxy"))
    stop("Invalid pc parameter; parcoords proxy object was expected")

  msg <- list(
    id = pc$id,
    calls = list(
      list(
        dependencies = lapply(pc$dependencies, shiny::createWebDependency),
        method = method,
        args = args
      )
    )
  )

  sess <- pc$session
  if (pc$deferUntilFlush) {
    sess$onFlushed(function() {
      sess$sendCustomMessage("parcoords-calls", msg)
    }, once = TRUE) # nolint
  } else {
    sess$sendCustomMessage("parcoords-calls", msg)
  }
  pc
}




#' Send commands to a Proxy instance in a Shiny app
#'
#' Creates a parcoords-like object that can be used to customize and control a parcoords
#' that has already been rendered. For use in Shiny apps and Shiny docs only.
#'
#' Normally, you create a parcoords chart using the \code{\link{parcoords}} function.
#' This creates an in-memory representation of a parcoords that you can customize.
#' Such a parcoords can be printed at the R console, included in an R Markdown
#' document, or rendered as a Shiny output.
#'
#' In the case of Shiny, you may want to further customize a parcoords, even after it
#' is rendered to an output. At this point, the in-memory representation of the
#' parcoords is long gone, and the user's web browser has already realized the
#' parcoords instance.
#'
#' This is where \code{parcoordsProxy} comes in. It returns an object that can
#' stand in for the usual parcoords object. The usual parcoords functions
#' can be called, and instead of customizing an in-memory representation,
#' these commands will execute on the live parcoords instance.
#'
#' @param parcoordsId single-element character vector indicating the output ID of the
#'   parcoords to modify (if invoked from a Shiny module, the namespace will be added
#'   automatically)
#' @param session the Shiny session object to which the map belongs; usually the
#'   default value will suffice
#' @param deferUntilFlush indicates whether actions performed against this
#'   instance should be carried out right away, or whether they should be held
#'   until after the next time all of the outputs are updated; defaults to
#'   \code{TRUE}
#'
#' @export
parcoordsProxy <- function(parcoordsId, session = shiny::getDefaultReactiveDomain(),
  deferUntilFlush = TRUE) {

  if (is.null(session)) {
    stop("parcoordsProxy must be called from the server function of a Shiny app")
  }

  # If this is a new enough version of Shiny that it supports modules, and
  # we're in a module (nzchar(session$ns(NULL))), and the parcoordsId doesn't begin
  # with the current namespace, then add the namespace.
  #
  # We could also have unconditionally done `parcoordsId <- session$ns(parcoordsId)`, but
  # older versions of Parcoords would have broken unless the user did session$ns
  # themselves, and we hate to break their code unnecessarily.
  #
  # This won't be necessary in future versions of Shiny, as session$ns (and
  # other forms of ns()) will be smart enough to only namespace un-namespaced
  # IDs.
  if (
    !is.null(session$ns) &&
    nzchar(session$ns(NULL)) &&
    substring(parcoordsId, 1, nchar(session$ns(""))) != session$ns("")
  ) {
    parcoordsId <- session$ns(parcoordsId)
  }

  structure(
    list(
      session = session,
      id = parcoordsId,
      x = structure(
        list()
      ),
      deferUntilFlush = deferUntilFlush,
      dependencies = NULL
    ),
    class = "parcoords_proxy"
  )
}
