Note:  this is very pre-alpha, but should be close to complete by the end of the week

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

