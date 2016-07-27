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
  rownames = TRUE,
  brushMode = "1d",
  reorderable = TRUE,
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

  // reverse order of cylinders
  this.parcoords.dimensions()['cyl']
      .yscale
      .domain(
        this.parcoords.dimensions()['cyl'].yscale.domain().reverse()
      );

  this.parcoords.removeAxes();
  this.parcoords.render();

  // duplicated from the widget js code
  //  to make sure reorderable and brushes work
  if( this.x.options.reorderable ) {
    this.parcoords.reorderable();
  } else {
    this.parcoords.createAxes();
  }

  if( this.x.options.brushMode ) {
    // reset the brush with None
    this.parcoords.brushMode('None')
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


parcoords(
  mtcars
  ,rownames = F
  ,brushMode = "1d-multi"
  ,brushPredicate = "OR"
  ,dimensions = list(
    cyl = list(
      title = "cylinder",
      tickValues = unique(mtcars$cyl)
    )
  )
)
