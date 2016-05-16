HTMLWidgets.widget({

  name: 'parcoords',

  type: 'output',

  factory: function(el, width, height) {

    var instance = {};

    var draw = function(){

      var x = instance.x;
      var parcoords = instance.parcoords;

      if( typeof x.options.rownames == "undefined" || x.options.rownames === false ) {
        //rownames = F so hide the axis
        parcoords.hideAxis(["names"]);
      }

      //identify the brushed elements and return those data IDs to Rshiny
      //the parcoords.on("brush",function(d)){} only works with 1D-axes selection
      if (HTMLWidgets.shinyMode){
        parcoords.on("render", function() {
          var ids = [];
          if(this.brushed()){
            ids = this.brushed().map(function(d){
              return d.names;
            })
          }

          //return the brushed row names
          if(Shiny.onInputChange){
            Shiny.onInputChange(el.id + "_brushed_row_names", ids);
          }
        });
      }

      // customize our parcoords according to options
      Object.keys( x.options ).filter(function(k){ return k !== "reorderable" && k !== "brushMode" && k !== "brushPredicate" && k!== "color" && k!=="rownames" }).map( function(k) {
        // if the key exists within parcoords
        if ( parcoords[k] ){
          if( typeof x.options[k] === "boolean" ){
            try {
              parcoords[k]();
            } catch(e) {
              console.log( "key/option: " + k + " did not work so ignore for now." )
            }
          } else {
            try{
              parcoords[k]( x.options[k] );
            } catch(e) {
              console.log( "key/option: " + k + " with value " + x.options[k] + "did not work so ignore for now." )
            }
          }
        } else {
          console.log( "key/option: " + k + " is not available for customization." )
        }
      })

      // color option will require some custom handling
      //   if color is an object with colorScale and colorBy
      //    will need to iterate through each of the unique group values
      //    and assign a color
      if ( typeof x.options.color !== "undefined" ) {
        var color;
        if( x.options.color.constructor.name === "Object" ) {
          colorScale = x.options.color.colorScale  ? x.options.color.colorScale : d3.scale.category20b();
          var colors = {};
          d3.keys(d3.nest().key(function(d){return d[x.options.color.colorBy]}).map(x.data)).map(function(c){
            colors[c] = colorScale(c);
          })

          color = function(d) {
            return colors[d[x.options.color.colorBy]];
          };
        } else {
          //   color can be a single value in which all lines will be same color
          //    for this we do not need to do anything
          color = x.options.color;
        }

        parcoords.color( color );
      }

      // now render our parcoords
      parcoords
        .render()

      if( x.options.reorderable ) {
        parcoords.reorderable();
      } else {
        parcoords.createAxes();
      }

      if( x.options.brushMode ) {
        parcoords.brushMode(x.options.brushMode);
        parcoords.brushPredicate(x.options.brushPredicate);
      }

      // if rownames = T then remove axis title
      if( typeof x.options.rownames !== "undefined" && x.options.rownames === true ) {
        d3.select("#" + el.id + " .dimension .axis > text").remove();
      }

      // sloppy but for now let's force text smaller
      //   ?? how best to provide parameter in R
      d3.selectAll("#" + el.id + " svg text")
          .style("font-size","10px");

      // set up a container for tasks to perform after completion
      //  one example would be add callbacks for event handling
      //  styling
      if (!(typeof x.tasks === "undefined" || x.tasks === null) ){
        if ( (typeof x.tasks.length === "undefined") ||
         (typeof x.tasks === "function" ) ) {
           // handle a function not enclosed in array
           // should be able to remove once using jsonlite
           x.tasks = [x.tasks];
        }
        x.tasks.map(function(t){
          // for each tasks call the task with el supplied as `this`
          t.call({el:el,parcoords:parcoords});
        });
      }
    };

    return {

      renderValue: function(x) {

        // basic check of data to make sure we received
        //   in column format or object of arrays
        //   which is the default behavior of htmlwidgets
        //   reason for this check is
        //      future-proofing if behavior changes
        //      someone supplies data in an atypical way
        if( x.data.constructor.name === "Object" ){
          // use HTMLWidgets function to convert to an array of objects (row format)
          x.data = HTMLWidgets.dataframeToD3( x.data )
        }

        // delete all children of el
        //  possibly revisit to see if we should be a little more delicate
        d3.select( el ).selectAll("*").remove();

        // create our parallel coordinates
        var parcoords = d3.parcoords()("#" + el.id)
          .data( x.data );


        // use expando to attach parcoords to the element
        //  this duplicates the step below
        //  but might make it easier for a user
        //  to manipulate the parcoords
        //  if they are not familiar with the
        //  internals of htmlwidgets
        el.parcoords = parcoords;
        // also attach the parallel coordinates and x to instance
        instance.parcoords = parcoords;
        instance.x = x;

        draw();

      },

      resize: function(width, height) {

        // only resize if autoresize set to TRUE
        //   resize will cause the entire parcoords to re-render
        //   so brushed selections, etc. will be lost
        //   and in event of bigger data, expensive re-render
        //   will occur
        if(instance.x.autoresize){
          var w = el.getBoundingClientRect().width;
          var h = el.getBoundingClientRect().height;

          instance.parcoords.width(w);
          instance.parcoords.height(h);

          draw();

        }

      }

    };
  }
});
