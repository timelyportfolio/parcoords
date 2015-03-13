\dontrun{
  library(shiny)
  library(parcoords)

  ui = shinyUI(
    fluidPage(fluidRow(
      column(width=6
        ,parcoordsOutput( "parcoords", width = "500px", height = "300px" )
      )
      ,column(width=6
        ,plotOutput( "iris_pairs", width = "400px" )
      )
    ))
  )

  server = function(input,output,session){
    output$parcoords = renderParcoords(
      parcoords(
        iris[,c(5,1:4)]  # order columns so species first
        , rownames=F
        , brushMode="1d"
        , color = list(
          colorScale = htmlwidgets::JS(sprintf(
            'd3.scale.ordinal().range(%s).domain(%s)'
            ,jsonlite::toJSON(RColorBrewer::brewer.pal(3,'Set1'))
            ,jsonlite::toJSON(as.character(unique(iris$Species)))
          ))
          ,colorBy = "Species"
        )
      )
    )

    output$iris_pairs = renderPlot({
      rows <- if(length(input$parcoords_brushed_row_names) > 0) {
        input$parcoords_brushed_row_names
      } else {
        rownames(iris)
      }
      # example from ?pairs
      pairs(
        iris[rows,-5]
        , main = "Anderson's Iris Data -- 3 species"
        , pch = 21
        , bg = RColorBrewer::brewer.pal(3,'Set1')[unclass(iris[rows,]$Species)]
      )
    })
  }

  shinyApp(ui,server)

}
