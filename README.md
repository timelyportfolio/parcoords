[![CRAN status](https://www.r-pkg.org/badges/version/parcoords)](https://cran.r-project.org/package=parcoords)
[![Travis build status](https://travis-ci.org/timelyportfolio/parcoords.svg?branch=master)](https://travis-ci.org/timelyportfolio/parcoords)

# parcoords | htmlwidget for d3 parallel-coordinates chart

`parcoords` gives `R` users the very well designed and interactive [`parallel-coordinates`](https://github.com/BigFatDog/parcoords-es) chart for `d3` with the infrastructure, flexibility, and robustness of [`htmlwidgets`](http://htmlwidgets.org).  `parcoords` began in the Building Widgets blog series [Week 04 | Interactive Parallel Coordinates](http://www.buildingwidgets.com/blog/2015/1/30/week-04-interactive-parallel-coordinates-1) and has been refined and improved through production usage in various disciplines.

```
# from CRAN
# install.packages("parcoords")
# for the latest release
# devtools::install_github("timelyportfolio/parcoords")

library(parcoords)

data(mtcars)

parcoords(
  mtcars
  ,reorderable = TRUE
  ,brushMode = "2d-strums"
)
```

### Code of Conduct

Please note that the 'parcoords' project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.  I would love for anyone to participate, but please let's be friendly and welcoming.
