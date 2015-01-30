HTMLWidgets.widget({

  name: 'parcoords',

  type: 'output',

  initialize: function(el, width, height) {

    return { }

  },

  renderValue: function(el, x, instance) {

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
      .data( x.data )

    // customize our parcoords according to options
    Object.keys( x.options ).filter(function(k){ return k !== "reorderable" && k !== "brushMode" && k!== "color" && k!=="rownames" }).map( function(k) {
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
      if ( x.options.brushMode === "2D-strums" ) {
        x.options.margin.left = 0;
        parcoords.margin( x.options.margin );
        parcoords.render();
        console.log( "changing left margin to 0 to work with 2d brush" );
      }
      parcoords.brushMode(x.options.brushMode);
    }

    // if rownames = T then remove axis title
    if( typeof x.options.rownames !== "undefined" && x.options.rownames === true ) {
      d3.select("#" + el.id + " .dimension .axis > text").remove();
    }

    // sloppy but for now let's force text smaller
    //   ?? how best to provide parameter in R
    d3.selectAll("#" + el.id + " svg text")
        .style("font-size","10px");

    // use expando to attach parcoords to the element
    el.parcoords = parcoords;
    // also attach the parallel coordinates to instance
    instance.parcoords = parcoords;

  },

  resize: function(el, width, height, instance) {

  }

});
