### Help Me/Pay Me to Use, Improve, and Extend

Note:  this is a working [`htmlwidget`](http://htmlwidgets.org) first [released](http://www.buildingwidgets.com/blog/2015/1/30/week-04-interactive-parallel-coordinates-1) in the [Building Widgets](http://buildingwidgets.org) htmlwidget-a-week project.  `parcoords` has already seen extensive use in many projects across multiple domains.  If you have any interest in collaborating with me on this project or applying `parcoords`, please let me know (see [Time Isn't Money](http://www.buildingwidgets.com/blog/2016/2/12/time-isnt-money)).

# parcoords | htmlwidget for d3 parallel-coordinates chart

`parcoords` gives `R` users the very well designed and interactive [`parallel-coordinates`](http://syntagmatic.github.com/parallel-coordinates/) chart for `d3` with the infrastructure, flexibility, and robustness of [`htmlwidgets`](http://htmlwidgets.org).

```
# not on CRAN so use devtools::install_github to try it out
# devtools::install_github("timelyportfolio/parcoords")

library(parcoords)

data(mtcars)

parcoords(
  mtcars
  ,reorderable = T
  ,brushMode = "2d-strums"
)
```

