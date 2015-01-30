#' htmlwidget for d3.js parallel-coordinates
#'
#' Create interactive parallel coordinates charts with this htmlwidget
#' wrapper for d3.js \href{http://syntagmatic.github.io/parallel-coordinates/}{parallel-coordinates}.
#'
#' @param data  data.frame with data to use in the chart
#' @param rownames logical use rownames from the data.frame in the chart
#' @param color see \href{https://github.com/syntagmatic/parallel-coordinates#parcoords_color}{parcoords.color( color )}.
#'          Color can be a single color as rgb or hex.  For a color function,
#'          provide a list( colorScale = , colorBy = ) where colorScale is
#'          a function such as \code{d3.scale.category10()} and colorBy
#'          is the column name from the data to determine color.
#' @param brushMode string, either \code{"1D-axes"} or \code{"2D-strums"},
#'          giving the type of desired brush behavior for the chart. Currently
#'          \code{brushMode = "2D-strums"} requires left margin = 0, so
#'          this will change automatically and might result in unexpected
#'          behavior.
#' @param reorderable logical enable reordering of axes
#' @param axisDots logical mark the points where polylines meet an axis with dots
#' @param margin list of sizes of margins in pixels.  Currently
#'          \code{brushMode = "2D-strums"} requires left margin = 0, so
#'          this will change automatically and might result in unexpected
#'          behavior.
#' @param composite foreground context's composite type
#'          see \href{https://github.com/syntagmatic/parallel-coordinates#parcoords_composite}{parcoords.composite}
#' @param alpha opacity from 0 to 1 of the polylines
#' @param queue logical (default FALSE) to change rendering mode to queue for
#'          progressive rendering.  Usually \code{ queue = T } for very large datasets.
#' @param mode string see\code{queue} above; \code{ queue = T } will set
#'          \code{ mode = "queue" }
#' @param rate integer rate at which render will queue; see \href{https://github.com/syntagmatic/parallel-coordinates#parcoords_rate}{}
#'          for a full discussion and some recommendations
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
#'
#'   # various ways to change color
#'   #   in these all lines are the specified color
#'   parcoords( mtcars, color = "green" )
#'   parcoords( mtcars, color=RColorBrewer::brewer.pal(3,"BuPu")[3] )
#'   parcoords( mtcars, color = "#f0c" )
#'   #   in these we supply a function for our color
#'   parcoords(
#'     mtcars
#'     , color = list(
#'        colorBy="cyl"
#'        ,colorScale=htmlwidgets::JS('d3.scale.category10()')
#'     )
#'   )
#'   ### be careful; this might strain your system #######
#'   ###                                           #######
#'   data( diamonds, package = "ggplot2" )
#'   parcoords(
#'     diamonds
#'     ,rownames=F
#'     ,brushMode = "1d-axes"
#'     ,reorderable=T
#'     ,queue = T
#'     ,color= list(
#'        colorBy="cut"
#'        ,colorScale = htmlwidgets::JS("d3.scale.category10()")
#'      )
#'   )
#'   # or if we want to add in a dplyr chain
#'   library(dplyr)
#'   data( diamonds, package = "ggplot2" )
#'   diamonds %>%
#'     mutate( carat = cut(carat,breaks = c(0,1,2,3,4,5), right =F) ) %>%
#'     group_by( carat ) %>%
#'     summarise_each(funs(mean),-carat) %>%
#'     parcoords(
#'       rownames= F
#'       ,color = list(
#'          colorScale = htmlwidgets::JS('d3.scale.category10()' )
#'         , colorBy = "carat"
#'       )
#'       ,brushMode = "1D"
#'     )
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
  , axisDots = NULL
  , margin = NULL
  , composite = NULL
  , alpha = NULL
  , queue = F
  , mode = F
  , rate = NULL
  , width = NULL
  , height = NULL
) {

  # verify that data is a data.frame
  if(!is.data.frame(data)) stop( "data parameter should be of type data.frame", call. = FALSE)

  # add rownames to data if rownames = T
  if( rownames == TRUE ) data = data.frame( "names" = rownames(data), data, stringsAsFactors = F )

  # check for valid brushMode
  #  should be either "1D-axes" or "2D-strums"
  if ( !is.null(brushMode) ) {
    if( grepl( x= brushMode, pattern = "2[dD](-)*([Ss]trum)*" ) ) {
      brushMode = "2D-strums"
      warning ( "brushMode 2D-strums requires left margin = 0, so changing")
    } else if( grepl( x= brushMode, pattern = "1[dD](-)*([Aa]x[ie]s)*" ) ) {
      brushMode = "1D-axes"
    } else {
      warning( paste0("brushMode ", brushMode, " supplied is incorrect"), call. = F )
      brushMode = NULL
    }
  }

  # make margin an option, so will need to modifyList
  if( !is.null(margin) && !is.list(margin) ){
    warning("margin should be a list like margin = list(top=20); assuming margin should be applied for all sides")
    margin = list( top=margin, bottom=margin, left=margin, right = margin)
  }
  if( is.list(margin) ){
    margin =  modifyList(list(top=50,bottom=50,left=100,right=50), margin )
  } else {
    margin = list(top=50,bottom=50,left=100,right=50)
  }

  # queue=T needs to be converted to render = "queue"
  if (!is.null(queue) && queue) mode = "queue"

  # forward options using x
  x = list(
    data = data,
    options = list(
      color = color
      , brushMode = brushMode
      , reorderable = reorderable
      , axisDots = axisDots
      , margin = margin
      , composite = composite
      , alpha = alpha
      , mode = mode
      , rate = rate
      , width = width
      , height = height
    )
  )

  # remove NULL options
  x$options = Filter( Negate(is.null), x$options )

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
