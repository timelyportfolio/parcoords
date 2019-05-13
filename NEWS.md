# parcoords 0.6.0

* update source JavaScript library to modular [parcoords-es](https://github.com/bigfatdog/parcoords-es) to stay current with [d3](https://github.com/d3/d3) and avoid conflicts with other versions of `d3`

* add proxy and methods for control and use of a `parcoords` htmlwidget from Shiny

* rework color argument completely to allow for coloring by a continuous variable and provide more flexibility for future use.  Now we can also eliminate `htmlwidgets::JS` from the argument so that the R user does not need to write JavaScript functions.

* allow horizontal scrolling when parcoords bigger than screen

* add center method for horizontally centering parcoords based on a column/dimension
