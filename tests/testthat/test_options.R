test_that("basic creation",{
  expect_is( parcoords(data.frame()), c("parcoords","htmlwidget")  )
  expect_error( parcoords() )
})

test_that("options",{
  # use mtcars dataset
  data(mtcars)

    # check rownames T
  expect_identical( parcoords(mtcars)$x$data, data.frame(names = rownames(mtcars),mtcars,stringsAsFactors=F ))
  # check rownames F
  expect_identical( parcoords(mtcars,rownames=F)$x$data, mtcars )

})
