library(crosstalk)
library(parcoords)
library(htmltools)
library(plotly)

sd <- crosstalk::SharedData$new(mtcars, group="grp1")

pc <- parcoords(sd, brushMode="1d", reorderable=TRUE)

pc

# see if it syncs with itself
tagList(pc,pc,pc) %>% browsable()

# try it with plotly as a test
tagList(
  tags$div(style="display:block;float:left;",
    plot_ly(sd, height=400, width=400) %>%
      add_markers(x=~hp, y=~mpg)
  ),
  tags$div(style="display:block;float:left;",
    modifyList(pc,list(height=400, width=600))
  )
) %>%
  browsable()
