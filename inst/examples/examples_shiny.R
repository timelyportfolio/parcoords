library(parcoords)
library(shiny)

ui <- tagList(
  textOutput("filteredstate", container=h3),
  parcoordsOutput("pc")
)

server <- function(input, output, session) {
  rv <- reactiveValues(filtered = FALSE)

  output$pc <- renderParcoords({
    parcoords(mtcars)
  })

  observe({
    # toggle between filtered and unfiltered every 2.5 seconds
    invalidateLater(2500)
    rv$filtered <- !isolate(rv$filtered)
  })

  observeEvent(rv$filtered, {
    # create a proxy with which we will communicate between
    #   Shiny and the parallel coordinates without a re-render
    pcp <- parcoordsProxy("pc")

    if(rv$filtered) {
      pcFilter(
        pcp,
        list(
          cyl = c(6,8),
          hp = list(gt = 200)
        )
      )
    } else {
      pcFilter(pcp, list())
    }
  })

  output$filteredstate <- renderText({
    paste0("Filtered: ", rv$filtered)
  })
}

shinyApp(ui = ui, server = server)
