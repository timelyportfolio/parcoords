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
    Object.keys( x.options ).filter(function(k){ k !== "reorderable" }).map( function(k) {
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

    // now render our parcoords
    parcoords
      .render()

    if( x.options.reorderable ) {
      parcoords.reorderable();
    } else {
      parcoords.createAxes();
    }

    // use expando to attach parcoords to the element
    el.parcoords = parcoords;
    // also attach the parallel coordinates to instance
    instance.parcoords = parcoords;

  },

  resize: function(el, width, height, instance) {

  }

});
