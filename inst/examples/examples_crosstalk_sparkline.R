# devtools::install_github("rstudio/crosstalk@joe/simplify")
# devtools::install_github("timelyportfolio/parcoords@feature/crosstalk2")

library(parcoords)
library(sparkline)
library(crosstalk)
library(htmlwidgets)
library(htmltools)

sd <- SharedData$new(mtcars, group="grp1")
pc <- parcoords(sd,brushMode="1d-axes")

spark_mpg <- sparkline(
  mtcars$mpg,
  type="box",
  chartRangeMin=0,
  chartRangeMax=max(mtcars$mpg),
  elementId = "sparkline-mpg"
)
spark_disp <- sparkline(
  mtcars$disp,
  type="box",
  chartRangeMin=0,
  chartRangeMax=max(mtcars$disp),
  elementId = "sparkline-disp"
)

browsable(tagList(
  tags$div(
    tags$span(style="font-style:bold","mpg"),
    tags$br(),
    spark_mpg,
    tags$br(),
    modifyList(spark_mpg,list(elementId="sparkline-mpg-selected"))
  ),
  tags$div(
    tags$span(style="font-style:bold","disp"),
    tags$br(),
    spark_disp,
    tags$br(),
    modifyList(spark_disp,list(elementId="sparkline-disp-selected"))
  ),
  # hack to make data available to window/global
  #  probably should not be considered best practice
  onRender(
    pc,
    "function(el,x){window.mtcars = x.data}"
  ),
  tags$script(
    HTML(sprintf(
"
var drawBox = function(selection){
  //make sure mtcars is available first
  //  since this will likely run before
  //  we run assignment of mtcars after parcoords render
  if(mtcars){
    var selected_rows = mtcars;
    if(selection && selection.length > 0){
      selection = Array.isArray(selection) ? selection : [selection];
      selected_rows = mtcars.filter(function(d){
        return selection.indexOf(d.key_) >= 0
      });
    }
    $('#sparkline-mpg-selected').sparkline(
      selected_rows.map(function(d){return d.mpg}),
      {type:'box',chartRangeMin:0,chartRangeMax:%i}
    );
    $('#sparkline-disp-selected').sparkline(
      selected_rows.map(function(d){return d.disp}),
      {type:'box',chartRangeMin:0,chartRangeMax:%i}
    );
  }
};

var sel_handle = new crosstalk.SelectionHandle('grp1');
sel_handle.on(
  'change',
  function(val){drawBox(val.value)}
);
"         ,
      ceiling(max(mtcars$mpg)),
      ceiling(max(mtcars$disp))
    )
  ))
))
