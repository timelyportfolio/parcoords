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
  # check brushmode
  expect_null( parcoords( data.frame(), brushMode = "something" )$x$options$brushMode )
  expect_match( parcoords( data.frame(), brushMode = "1d" )$x$options$brushMode, "1D-axes" )
  expect_match( parcoords( data.frame(), brushMode = "1D-axis" )$x$options$brushMode, "1D-axes" )
  expect_match( parcoords( data.frame(), brushMode = "2d" )$x$options$brushMode, "2D-strums" )
  expect_match( parcoords( data.frame(), brushMode = "2Dstrum" )$x$options$brushMode, "2D-strums" )
})
