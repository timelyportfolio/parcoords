library(shiny)
library(shinydashboard)
library(dplyr)
library(parcoords)


body <- dashboardBody(
  box(
    title = "Parcoords Plot Example", width = NULL, status = "primary",
    parcoordsOutput("DiamondPlot")
  ),
  box(
    title = "Extracted Data", width = NULL, status = "primary",
    dataTableOutput("SelectedData")
  )
)

ui <- dashboardPage(
  dashboardHeader(title="Parcoords"),
  dashboardSidebar(disable=TRUE),
  body
)



server = function(input, output, session) {
  ###generate a data set to use
  data( diamonds, package = "ggplot2" )
  DiamondData <-   diamonds %>%
    mutate( carat = cut(carat,breaks = c(0,1,2,3,4,5), right =F) ) %>%
    group_by( carat ) %>%
    summarise_each(funs(mean),-carat)

  ###Add an ID field called "DataId" so the js can identify which column is your
  ###unique identifier when brushed and exported back to shiny through input$id_brushed_row_names
  ##DiamondData$DataID <- 1:nrow(DiamondData)

  ###standard parcoords plot in shiny

  output$DiamondPlot <- renderParcoords({
    parcoords(DiamondData,rownames= T,
              color = list(colorScale = htmlwidgets::JS('d3.scale.category10()'),
                            colorBy = "carat"),
              brushMode = "2D-strums")
  })

  ###Here we can access the variable input$id_rows to determine which are selected
  ###we display these results in a table
  output$SelectedData <- renderDataTable({
    ids <- rownames(DiamondData) %in% input$DiamondPlot_brushed_row_names
    DiamondData[ids,]
  })

}

shinyApp(ui, server)
