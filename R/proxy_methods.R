
#' Filter \code{parcoords} through \code{parcoordsProxy}
#'
#' @param pc \code{parcoordsProxy}
#' @param filters \code{list} of filters to apply to the parcoords proxy.  Please see
#'   \href{https://github.com/deitch/searchjs}{search.js} for example queries as filters.
#'
#' @return \code{parcoords_proxy}
#' @rdname parcoords_methods
#' @export
#'
pcFilter <- function(pc=NULL, filters = NULL) {
  if(!inherits(pc, "parcoords_proxy")) {
    stop(
      paste0("expecting pc argument to be parcoordsProxy but got ", class(pc)),
      call. = FALSE
    )
  }

  invokeRemote(pc, "filter", list(filters))
  pc
}
