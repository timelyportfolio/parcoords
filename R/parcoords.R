#' htmlwidget for d3.js parallel-coordinates
#'
#' Create interactive parallel coordinates charts with this htmlwidget
#' wrapper for d3.js \href{http://syntagmatic.github.io/parallel-coordinates/}{parallel-coordinates}.
#'
#' @param data  data.frame with data to use in the chart
#' @param rownames logical use rownames from the data.frame in the chart.  Regardless of
#'          this parameter, we will append rownames to the data that we send to JavaScript.
#'          If \code{rownames} equals \code{FALSE}, then we will use parallel coordinates
#'          to hide it.
#' @param color see \href{https://github.com/syntagmatic/parallel-coordinates\#parcoords_color}{parcoords.color( color )}.
#'          Color can be a single color as rgb or hex.  For a color function,
#'          provide a list( colorScale = , colorBy = ) where colorScale is
#'          a function such as \code{d3.scale.category10()} and colorBy
#'          is the column name from the data to determine color.
#' @param brushMode string, either \code{"1D-axes"}, \code{"1D-axes-multi"},
#'          or \code{"2D-strums"}
#'          giving the type of desired brush behavior for the chart.
#' @param brushPredicate string, either \code{"and"} or \code{"or"} giving
#'          the logic forthe join with multiple brushes.
#' @param reorderable logical enable reordering of axes
#' @param axisDots logical mark the points where polylines meet an axis with dots
#' @param margin list of sizes of margins in pixels.  Currently
#'          \code{brushMode = "2D-strums"} requires left margin = 0, so
#'          this will change automatically and might result in unexpected
#'          behavior.
#' @param composite foreground context's composite type
#'          see \href{https://github.com/syntagmatic/parallel-coordinates\#parcoords_composite}{parcoords.composite}
#' @param alpha opacity from 0 to 1 of the polylines
#' @param queue logical (default FALSE) to change rendering mode to queue for
#'          progressive rendering.  Usually \code{ queue = T } for very large datasets.
#' @param mode string see\code{queue} above; \code{ queue = T } will set
#'          \code{ mode = "queue" }
#' @param rate integer rate at which render will queue; see \href{https://github.com/syntagmatic/parallel-coordinates\#parcoords_rate}{}
#'          for a full discussion and some recommendations
#' @param dimensions \code{list} to customize axes dimensions.
#' @param tasks a character string or \code{\link[htmlwidgets]{JS}} or list of
#'          strings or \code{JS} representing a JavaScript function(s) to run
#'          after the \code{parcoords} has rendered.  These provide an opportunity
#'          for advanced customization.  Note, the \code{function} will use the
#'          JavaScript \code{call} mechanism, so within the function, \code{this} will
#'          be an object with {this.el} representing the containing element of the
#'          \code{parcoords} and {this.parcoords} representing the \code{parcoords}
#'          instance.
#' @param autoresize logical (default FALSE) to auto resize the parcoords
#'          when the size of the container changes.  This is useful
#'          in contexts such as rmarkdown slide presentations or
#'          flexdashboard.  However, this will not be useful if you
#'          expect bigger data or a more typical html context.
#' @param width integer in pixels defining the width of the widget.  Autosizing  to 100%
#'          of the widget container will occur if \code{ width = NULL }.
#' @param height integer in pixels defining the height of the widget.  Autosizing to 400px
#'          of the widget container will occur if \code{ height = NULL }.
#' @param elementId unique \code{CSS} selector id for the widget.
#' @param alphaOnBrushed opacity from 0 to 1 when brushed (default to 0).
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
#'      mutate( carat = cut(carat,breaks = pretty(carat), right =F) ) %>%
#'      group_by( carat ) %>%
#'      select(-c(cut,color,clarity)) %>%
#'      summarise_each(funs(mean),-carat) %>%
#'      parcoords(
#'         rownames= F
#'         ,color = list(
#'            colorScale = htmlwidgets::JS('d3.scale.category10()' )
#'           , colorBy = "carat"
#'         )
#'         ,brushMode = "1D"
#'       )
#' }
#' @example ./inst/examples/examples_dimensions.R
#'
#' @import htmlwidgets
#'
#' @export
parcoords <- function(
  data
  , rownames = T
  , color = NULL
  , brushMode = NULL
  , brushPredicate = "and"
  , reorderable = F
  , axisDots = NULL
  , margin = NULL
  , composite = NULL
  , alpha = NULL
  , queue = F
  , mode = F
  , rate = NULL
  , dimensions = NULL
  , tasks = NULL
  , autoresize = FALSE
  , width = NULL
  , height = NULL
  , elementId = NULL
  , alphaOnBrushed = NULL
) {

  # verify that data is a data.frame
  if(!is.data.frame(data)) stop( "data parameter should be of type data.frame", call. = FALSE)

  # add rownames to data
  #  rownames = F will tell us to hide these with JavaScript
  data = data.frame(
    "names" = rownames(data)
    , data
    , stringsAsFactors = FALSE
    , check.names = FALSE
  )

  # check for valid brushMode
  #  should be either "1D-axes" or "2D-strums"
  if ( !is.null(brushMode) ) {
    if( grepl( x= brushMode, pattern = "2[dD](-)*([Ss]trum)*" ) ) {
      brushMode = "2D-strums"
    } else if( grepl( x= brushMode, pattern = "1[dD](-)*([Aa]x[ie]s)*" ) ||
               grepl( x= brushMode, pattern = "[mM](ult)" )
     ) {
      if( grepl( x= brushMode, pattern = "[mM](ult)" ) ) {
        brushMode = "1D-axes-multi" }
      else if( grepl( x= brushMode, pattern = "1[dD](-)*([Aa]x[ie]s)*" ) ) {
        brushMode = "1D-axes"
      }
    } else {
      warning( paste0("brushMode ", brushMode, " supplied is incorrect"), call. = F )
      brushMode = NULL
    }
  }

  # upper case brushPredicate
  brushPredicate = toupper( brushPredicate )

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

  # convert character tasks to htmlwidgets::JS
  if ( !is.null(tasks) ){
    tasks = lapply(
      tasks,
      function(task){
        if(!inherits(task,"JS_EVAL")) task <- htmlwidgets::JS(task)
        task
      }
    )
  }

  # forward options using x
  x = list(
    data = data,
    options = list(
      rownames = rownames
      , color = color
      , brushMode = brushMode
      , brushPredicate = brushPredicate
      , reorderable = reorderable
      , axisDots = axisDots
      , margin = margin
      , composite = composite
      , alpha = alpha
      , mode = mode
      , rate = rate
      , dimensions = dimensions
      , width = width
      , height = height
      , alphaOnBrushed = alphaOnBrushed
    )
    , autoresize = autoresize
    , tasks = tasks
  )

  # remove NULL options
  x$options = Filter( Negate(is.null), x$options )

  # create widget
  htmlwidgets::createWidget(
    name = 'parcoords',
    x,
    width = width,
    height = height,
    package = 'parcoords',
    elementId = elementId
  )
}


#' Widget output function for use in Shiny
#'
#' @example man-roxygen/shiny.R
#'
#' @export
parcoordsOutput <- function(outputId, width = '100%', height = '400px'){
  shinyWidgetOutput(outputId, 'parcoords', width, height, package = 'parcoords')
}

#' Widget render function for use in Shiny
#'
#' @seealso \code{\link{parcoordsOutput}}
#'
#' @export
renderParcoords <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  shinyRenderWidget(expr, parcoordsOutput, env, quoted = TRUE)
}
