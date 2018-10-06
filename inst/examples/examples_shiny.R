library(parcoords)
library(shiny)

ui <- parcoordsOutput("pc")

server <- function(input, output, session) {
  output$pc <- renderParcoords(
    parcoords(mtcars)
  )

  pcp <<- parcoordsProxy("pc")
  pcFilter(
    parcoordsProxy("pc"),
    list(
      cyl = c(6,8),
      hp = list(gt = 200)
    )
  )
}

shinyApp(ui = ui, server = server)
