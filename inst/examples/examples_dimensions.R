library(parcoords)

parcoords(
  mtcars,
  dimensions = list(
    cyl = list(
      title = "cylinder",
      tickValues = unique(mtcars$cyl)
    )
  )
)

parcoords(
  mtcars
  ,rownames = FALSE
  ,brushMode = "1d-multi"
  ,brushPredicate = "OR"
  ,dimensions = list(
    cyl = list(
      title = "cylinder",
      tickValues = unique(mtcars$cyl)
    )
  )
)
