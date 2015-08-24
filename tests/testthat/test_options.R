test_that("basic creation",{
  expect_is( parcoords(data.frame()), c("parcoords","htmlwidget")  )
  expect_error( parcoords() )
})

test_that("options",{
  # use mtcars dataset
  data(mtcars)

  # will add rownames to the data regardless of rownames parameter
  expect_identical( parcoords(mtcars)$x$data, data.frame(names = rownames(mtcars),mtcars,stringsAsFactors=F ))
  # make sure rownames is passed through
  expect_true( !parcoords( data.frame(), rownames=F )$x$options$rownames )

  # check brushmode
  #   this is designed to be flexible and forgiving
  expect_null( suppressWarnings(parcoords( data.frame(), brushMode = "something" ))$x$options$brushMode )
  expect_warning( parcoords( data.frame(), brushMode = "something" ) )
  expect_match( parcoords( data.frame(), brushMode = "1d" )$x$options$brushMode, "1D-axes" )
  expect_match( parcoords( data.frame(), brushMode = "1D-axis" )$x$options$brushMode, "1D-axes" )
  expect_match( parcoords( data.frame(), brushMode = "2d" )$x$options$brushMode, "2D-strums" )
  expect_match( parcoords( data.frame(), brushMode = "2Dstrum" )$x$options$brushMode, "2D-strums" )
  expect_match( parcoords( data.frame(), brushMode = "multi" )$x$options$brushMode, "1D-axes-multi" )
  expect_match( parcoords( data.frame(), brushMode = "1d-multi" )$x$options$brushMode, "1D-axes-multi" )

  # make sure brushpredicate gets uppercase
  expect_match( parcoords( data.frame(), brushPredicate = "and" )$x$options$brushPredicate, "AND" )
  expect_match( parcoords( data.frame(), brushPredicate = "Or" )$x$options$brushPredicate, "OR" )

  # check margins
  expect_identical(
    parcoords(data.frame())$x$options$margin
    ,list( top = 50, bottom = 50, left=100, right = 50)
  )
  #   if single numeric then apply param to all sides
  expect_identical(
    parcoords(data.frame(),margin=0)$x$options$margin
    ,list( top = 0, bottom = 0, left=0, right = 0)
  )
  expect_identical(
    parcoords(data.frame(),margin=list(top=10,left=10))$x$options$margin
    ,list( top = 10, bottom = 50, left=10, right = 50)
  )

  # check alpha
  expect_null( parcoords(data.frame() )$x$options$alpha )
  expect_equal( parcoords( data.frame(), alpha = 0.2 )$x$options$alpha, 0.2)

  # check that queue= T becomes mode = "queue"
  expect_match( parcoords( data.frame(), queue = T )$x$options$mode, "queue" )
  #   and that when queue is null does not overwrite mode
  expect_match( parcoords( data.frame(), queue = NULL, mode="queue" )$x$options$mode, "queue" )

  # check that rate gets transmitted
  expect_null( parcoords(data.frame() )$x$options$rate )
  expect_equal( parcoords(data.frame(), rate = 200)$x$options$rate, 200)
})
