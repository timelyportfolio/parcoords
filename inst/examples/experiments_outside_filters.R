#  using experiments-brush branch of parcoords

library(parcoords)
library(htmltools)

# get a parcoords that we can hack later
pc <- parcoords(
  mtcars,
  brushMode = "1d",
  height = 350
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


# try categorical axis selection
htmlwidgets::onRender(
  pc,
"
function(el, x) {
  var pc = this.instance.parcoords

  // hard code for now cyl will be 3rd dimension
  var dim_cyl = d3.select('.dimension:nth-of-type(3)')

  var sc_cyl = pc.dimensions().cyl.yscale

	var sc_y = d3.scale.ordinal()
    .domain([4,6,8])
    .rangeRoundBands(sc_cyl.range())

  var ax_y = d3.svg.axis()
    .scale(sc_y)
    .orient('left')

  dim_cyl.selectAll('.tick').remove()

  var g_ax = dim_cyl.append('g')
    .call(ax_y)

  var color = d3.scale.category10()

  g_ax.select('path').style('display', 'none')

  g_ax
  	.selectAll('.tick')
    .classed('selected', true)
  	.append('rect')
  	.attr('height', sc_y.rangeBand())
  	.attr('y', -sc_y.rangeBand()/2)
  	.attr('width', 10)
    .attr('x', -5)
  	.attr('fill', function(d){return color(d)})

  g_ax.selectAll('.tick')
    .style('opacity', 1)
  	.on('click', toggle)

  function toggle() {
    var selected = !d3.select(this).classed('selected')
    d3.select(this).classed('selected', selected)
    d3.select(this)
    	.style('opacity', selected ? 1 : 0.4)

    filter_pc(dim_cyl, 'cyl')
  }

  function filter_pc(el, dim) {
    var selected = []
    dim_cyl.selectAll('.selected').each(function(d) {
      selected.push(d)
    })
    var filters = pc.outsideFilters() || {}

    filters[dim] = selected
    pc.outsideFilters(filters)
    pc.brushUpdated(pc.selected())
  }
}
"
)
