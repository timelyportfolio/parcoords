library(crosstalk)
library(parcoords)
library(htmltools)
library(plotly)

sd <- crosstalk::SharedData$new(mtcars, group="grp1")

pc <- parcoords(sd, brushMode="1d")

pc

# see if it syncs with itself
tagList(pc,pc,pc) %>% browsable()

# try it with plotly as a test
tagList(
  plot_ly(sd) %>%
    add_markers(x=~hp, y=~mpg),
  pc
) %>%
  browsable()
