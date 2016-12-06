library(crosstalk)
library(parcoords)

sd <- crosstalk::SharedData$new(mtcars, group="grp1")

pc <- parcoords(sd, brushMode="1d")

pc

# try it with plotly as a test
library(htmltools)
library(plotly)

tagList(
  plot_ly(sd) %>%
    add_markers(x=~hp, y=~mpg),
  pc
) %>%
  browsable()
