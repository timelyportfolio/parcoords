#  using experiments-brush branch of parcoords

library(parcoords)
library(htmltools)

# get a parcoords that we can hack later
pc <- parcoords(
  mtcars,
  brushMode = "1d"
)

browsable(
  tagList(
    tags$select(
      name = "cyl",
      id = "select-cyl",
      multiple = "true",
      tags$option(4),
      tags$option(6),
      tags$option(8)
    ),
    pc,
    tags$script(HTML(
"
d3.select('#select-cyl').on('change', function() {
  var pc = HTMLWidgets.find('.parcoords').instance.parcoords
  var selected = []
  d3.select(this).selectAll('option:checked').each(function(d){
    selected.push(+this.value)
  })

  var filters = pc.outsideFilters() || {}

  if(selected.length > 0) {
    filters.cyl = selected
    pc.outsideFilters(filters)
  } else {
    delete filters.cyl
    pc.outsideFilters(filters)
  }

  // now update
  pc.brushUpdated(pc.selected())
})
"
    ))
  )
)
