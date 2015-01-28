#' htmlwidget for d3.js parallel-coordinates
#'
#' Create interactive parallel coordinates charts with this htmlwidget
#' wrapper for d3.js \href{http://syntagmatic.github.io/parallel-coordinates/}{parallel-coordinates}.
#'
#' @param data  data.frame with data to use in the chart
#' @param rownames logical use rownames from the data.frame in the chart
#' @param color see \href{https://github.com/syntagmatic/parallel-coordinates#parcoords_color}{parcoords.color( color )}
#' @param brushMode string, either \code{"1D-axes"} or \code{"2D-strums"},
#'          giving the type of desired brush behavior for the chart
#' @param reorderable logical enable reordering of axes
#' @param axisDots logical mark the points where polylines meet an axis with dots
#' @param margins list of sizes of margins in pixels
#' @param composite foreground context's composite type
#'          see \href{https://github.com/syntagmatic/parallel-coordinates#parcoords_composite}{parcoords.composite}
#' @param alpha opacity from 0 to 1 of the polylines
#' @param queue logical (default FALSE) to change rendering mode to queue for
#'          progressive rendering.  Usually \code{ queue = T } for very large datasets.
#' @param width integer in pixels defining the width of the widget.  Autosizing  to 100%
#'          of the widget container will occur if \code{ width = NULL }.
#' @param height integer in pixels defining the height of the widget.  Autosizing to 400px
#'          of the widget container will occur if \code{ height = NULL }.
#'
#' @return An object of class \code{htmlwidget} that will
#' intelligently print itself into HTML in a variety of contexts
#' including the R console, within R Markdown documents,
#' and within Shiny output bindings.
#' @examples
#' \dontrun{
#'   # simple example using the mtcars dataset
#'   data( mtcars )
#'   parcoords( mtcars )
#' }
#' @import htmlwidgets
#'
#' @export
parcoords <- function(
  data
  , rownames = T
  , color = NULL
  , brushMode = NULL
  , reorderable = F
  , axisDots = T
  , margins = list( bottom = 50, left = 50, top = 50, right = 50)
  , composite = NULL
  , alpha = NULL
  , queue = F
  , width = NULL
  , height = NULL
) {

  # verify that data is a data.frame
  if(!is.data.frame(data)) stop( "data parameter should be of type data.frame", call. = FALSE)

  # add rownames to data if rownames = T
  if( rownames == TRUE ) data = data.frame( "names" = rownames(data), data, stringsAsFactors = F )

  # forward options using x
  x = list(
    data = data,
    options = list( ..., width = width, height = height )
  )

  # remove NULL options
  x.options = Filter( Negate(is.null), x.options )

  # create widget
  htmlwidgets::createWidget(
    name = 'parcoords',
    x,
    width = width,
    height = height,
    package = 'parcoords'
  )
}

#' Widget output function for use in Shiny
#'
#' @export
parcoordsOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'parcoords', width, height, package = 'parcoords')
}

#' Widget render function for use in Shiny
#'
#' @export
renderParcoords <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, parcoordsOutput, env, quoted = TRUE)
}
