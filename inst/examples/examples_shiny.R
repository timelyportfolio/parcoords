if(interactive()) {
  #### filter proxy example ----

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

  ### center proxy example ----
  library(shiny)
  library(parcoords)

  ui <- tags$div(
    parcoordsOutput("pc", width = 2500),
    style="width: 2500px;"
  )

  server <- function(input, output, session) {
    # create a proxy with which we will communicate between
    #   Shiny and the parallel coordinates without a re-render
    pcp <- parcoordsProxy("pc")

    output$pc <- renderParcoords({
      parcoords(mtcars)
    })

    pcCenter(pcp, 'drat')
  }

  shinyApp(ui=ui, server=server)

  ### hide/unhide proxy example ----
  library(parcoords)
  library(shiny)

  ui <- tagList(
    selectizeInput(
      inputId = "columns",
      label = "Columns to Hide",
      choices = c("names",colnames(mtcars)),
      selected = "names",
      multiple = TRUE
    ),
    parcoordsOutput("pc"),
    checkboxInput("hidenames", label="Hide Row Names", value=TRUE),
    parcoordsOutput("pc2")
  )

  server <- function(input, output, session) {
    output$pc <- renderParcoords({
      parcoords(mtcars, rownames = FALSE, brushMode = "1d")
    })

    output$pc2 <- renderParcoords({
      parcoords(mtcars, rownames = FALSE)
    })

    pcUnhide

    observeEvent(input$columns, {
      # create a proxy with which we will communicate between
      #   Shiny and the parallel coordinates without a re-render
      pcp <- parcoordsProxy("pc")

      pcHide(pcp, input$columns)
    }, ignoreInit = TRUE, ignoreNULL = FALSE)

    observeEvent(input$hidenames, {
      # create a proxy with which we will communicate between
      #   Shiny and the parallel coordinates without a re-render
      pcp2 <- parcoordsProxy("pc2")
      if(input$hidenames) {
        pcHide(pcp2, "names")
      } else {
        pcUnhide(pcp2, "names")
      }
    })

  }

  shinyApp(ui = ui, server = server)


  ### snapshot example ----
  library(shiny)
  library(parcoords)

  ui <- tags$div(
    actionButton(inputId = "snapBtn", label = "snapshot"),
    parcoordsOutput("pc", height=400)
  )

  server <- function(input, output, session) {
    # create a proxy with which we will communicate between
    #   Shiny and the parallel coordinates without a re-render
    pcp <- parcoordsProxy("pc")

    output$pc <- renderParcoords({
      parcoords(mtcars)
    })

    observeEvent(input$snapBtn, {
      # create a proxy with which we will communicate between
      #   Shiny and the parallel coordinates without a re-render
      pcp <- parcoordsProxy("pc")
      pcSnapshot(pcp)
    })
  }

  shinyApp(ui=ui, server=server)
}
