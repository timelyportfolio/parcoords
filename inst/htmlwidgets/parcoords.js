HTMLWidgets.widget({

  name: 'parcoords',

  type: 'output',

  factory: function(el, width, height) {

    var instance = { };

    var draw = function(el, instance){

      var x = instance.x;

      //ugly but currently have to clear out
      //  each time to get proper render
      // delete all children of el
      //  possibly revisit to see if we should be a little more delicate
      d3.select( el ).selectAll("*").remove();

      // if height or width = 0 then bail
      //   this is important for flexdashboard and tabsets
      if(
        el.getBoundingClientRect().width === 0 ||
        el.getBoundingClientRect().height === 0
      ){
        return;
      }

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

      // separate from above Shiny handling for now,
      //   but eventually integrate
      var crosstalk_supported = typeof(crosstalk) !== "undefined" &&
          typeof(x.crosstalk_opts) !== "undefined";

      if(crosstalk_supported) {
        var ct_sel = new crosstalk.SelectionHandle(x.crosstalk_opts.group);
        parcoords.on("render", function() {
          var ids = [];
          if(
            this.brushed() &&
            this.brushed().length < parcoords.data().length
          ){
            ids = this.brushed().map(function(d){
              return d.key_;
            })
            // add brushed to filter
            ct_sel.set(ids);
            this.highlight(this.brushed());
          } else {
            parcoords.unhighlight();
            // instead set to empty array
            // first check to make sure parcoords initiated
            //  before clearing
            if(typeof(parcoords.brushResetter) !== "undefined" &&
                parcoords.brushResetter === "self"
            ) {
              // seems this sets to undefined
              //   which Plotly does not currently handle
              //ct_sel.clear();
              ct_sel.set(null);
            }
          }

        });
      }


      // handle dimensions;  it appears that parcoords
      //   detectDimensions does not run if custom dimensions
      //   are provided, so we'll need to detectDimensions
      //   and then in any that are specified
      if( x.options.dimensions ){
        parcoords.detectDimensions();
        var dims = parcoords.dimensions();
        // this is ugly but trying to avoid dependency
        // Object.assign did not work in RStudio
        Object.keys(x.options.dimensions).map(function(k){
          Object.keys(x.options.dimensions[k]).map(function(kk){
            dims[k][kk] = x.options.dimensions[k][kk];
          })
        })
        x.options.dimensions = dims;
      }

      // customize our parcoords according to options
      Object.keys( x.options ).filter(function(k){ return k !== "reorderable" && k !== "brushMode" && k !== "brushPredicate" && k!== "color" && k!=="rownames"}).map( function(k) {
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


      var hidden_axes = [];
      // at one point thought I should
      //   remove this because of bug with experimental dimensions
      //    and handle for now by removing rownames from the data
      // but instead I just had to move this piece to here
      if( typeof x.options.rownames == "undefined" || x.options.rownames === false ) {
        //rownames = F so hide the axis
        hidden_axes.push("names");
      }

      // hide crosstalk key column
      if(crosstalk_supported) {
        hidden_axes.push("key_");
      }

      parcoords.hideAxis(hidden_axes);

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
          t.call({el:el,parcoords:parcoords,x:x});
        });
      }

      // now that we have drawn and executed tasks
      //   wire up crosstalk selection from outside parcoords
      if(crosstalk_supported) {
        ct_sel.on("change", function(sel){
          if(!(
            typeof(ct_sel.value) === "undefined" ||
            ct_sel.value === null ||
            (Array.isArray(ct_sel.value) && ct_sel.value.length === 0)
          )) {
            var selected = ct_sel.value;

            // handle non-array single-value
            if(!Array.isArray(selected)) {
              selected = [selected];
            }
            if(sel.sender === ct_sel){
              // do nothing for now
            } else {
              // clear brushes
              if(parcoords.brushed()){
                // nasty way of determining source of brush reset
                //   need this to know whether to change
                //   crosstalk selection or if the brush reset
                //   is an outcome caused by something other than
                //   this parcoords changing the selection
                parcoords.brushResetter = "other";
                parcoords.brushReset();
                parcoords.brushResetter = "self";
              }
              // use highlight to show the selection
              parcoords.highlight(parcoords.data().filter(function(d,i) {
                return selected.indexOf(d.key_) >= 0;
              }));
            }
          } else {
            parcoords.unhighlight();
          }
        });
      }

      return instance;

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

        instance.x = x;

        instance = draw(el, instance);

      },

      resize: function(width, height) {

        // only resize if autoresize set to TRUE
        //   resize will cause the entire parcoords to re-render
        //   so brushed selections, etc. will be lost
        //   and in event of bigger data, expensive re-render
        //   will occur
        if(instance.x.autoresize){

          instance = draw(el, instance);

        }

      },

      instance: instance

    };
  }
});
