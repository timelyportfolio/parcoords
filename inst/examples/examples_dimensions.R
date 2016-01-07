# devtools::install_github("timelyportfolio/parcoords@feature/dimensions")

library(parcoords)

parcoords(
  mtcars,
  dimensions = list(
    cyl = list(
      title = "cylinder",
      tickValues = unique(mtcars$cyl)
    )
  )
)

parcoords(
  mtcars,
  brushMode = "2d",
  #reorderable = TRUE,
  dimensions = list(
    cyl = list(
      tickValues = c(4,6,8)
    )
  ),
  tasks = list(
    htmlwidgets::JS(sprintf(
"
function(){
  debugger
  this.parcoords.dimensions()['names']
      .yscale = d3.scale.ordinal()
        .domain([%s])
        .rangePoints([
          1,
          this.parcoords.height()-this.parcoords.margin().top - this.parcoords.margin().bottom
        ])

  this.parcoords.render()

  // duplicated from the widget js code
  //  to make sure reorderable and brushes work
  if( this.x.options.reorderable ) {
    this.parcoords.reorderable();
  } else {
    this.parcoords.createAxes();
  }

  if( this.x.options.brushMode ) {
    this.parcoords.brushMode(this.x.options.brushMode);
    this.parcoords.brushPredicate(this.x.options.brushPredicate);
  }

  // delete title from the rownames axis
  d3.select('#' + this.el.id + ' .dimension .axis > text').remove();
}
"     ,
      paste0(sort(shQuote(rownames(mtcars))),collapse=",")
    ))
  )
)
