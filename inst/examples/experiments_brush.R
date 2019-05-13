library(parcoords)
library(htmltools)

# experiment with controlling the brushes from outside input ----
pc <- parcoords(mtcars, brushMode="1d")
pc$x$tasks <- list(htmlwidgets::JS(
"
  function() {
    var el = this.el
    var pc = this.parcoords

    d3.select(el).style('position', 'relative')

    var mpg_vals = [10, 28]

    pc.brushExtents({mpg: mpg_vals})
    var mpgx

    d3.select(el).selectAll('g.dimension').each(function(d) {
      if (d === 'mpg') {
        mpgx = this.getBoundingClientRect().x - el.getBoundingClientRect().x
      }
    })

    var mpg_lower = d3.select(el).append('input')
      .attr('type', 'number')
      .style('position', 'absolute')
      .style('top', this.el.getBoundingClientRect().height + 'px')
      .style('left', mpgx + 'px')
      .style('width', '40px')
      .style('font-size', '0.75em')
      .property('value', mpg_vals[0])
      .on('input', function() {
        pc.brushExtents({
          mpg: [
            +d3.select(this).property('value'),
            pc.brushExtents() && pc.brushExtents().mpg ? pc.brushExtents().mpg[1] : pc.dimensions().mpg.yscale.domain()[1]
          ]
        })
      })

    var mpg_higher = d3.select(el).append('input')
      .attr('type', 'number')
      .style('position', 'absolute')
      .style('top', 0)
      .style('left', mpgx + 'px')
      .style('width', '40px')
      .style('font-size', '0.75em')
      .property('value', mpg_vals[1])
      .on('input', function() {
        pc.brushExtents({
          mpg: [
            pc.brushExtents() && pc.brushExtents().mpg ? pc.brushExtents().mpg[0] : pc.dimensions().mpg.yscale.domain()[0],
            +d3.select(this).property('value')
          ]
        })
      })

    pc.on('brush', function(d, br) {
      if(d3.select(br).datum() !== 'mpg') {return}
      if(+mpg_lower.property('value') !== this.brushExtents().mpg[0]) {
        mpg_lower.property('value', this.brushExtents().mpg[0])
      }
      if(+mpg_lower.property('value') !== this.brushExtents().mpg[1]) {
        mpg_higher.property('value', this.brushExtents().mpg[1])
      }
    })
  }
"
))
pc
