
#' Filter \code{parcoords} through \code{parcoordsProxy}
#'
#' @param pc \code{parcoordsProxy}
#' @param filters \code{list} of filters to apply to the parcoords proxy.  Please see
#'   \href{https://github.com/deitch/searchjs}{search.js} for example queries as filters.
#'
#' @return \code{parcoords_proxy}
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

#' Center \code{parcoords} horizontally based on column/variable through \code{parcoordsProxy}
#'
#' @param pc \code{parcoordsProxy}
#' @param dim \code{string} column/variable to center.
#'
#' @return \code{parcoords_proxy}
#' @export
#'
pcCenter <- function(pc=NULL, dim = NULL) {
  if(!inherits(pc, "parcoords_proxy")) {
    stop(
      paste0("expecting pc argument to be parcoordsProxy but got ", class(pc)),
      call. = FALSE
    )
  }

  invokeRemote(pc, "center", list(dim = dim))
  pc
}
