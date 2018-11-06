var methods = {};

methods.filter = function(filter) {
  this.filter(filter);
}

methods.center = function(dim) {
  this.center(dim);
}

methods.snapshot = function() {
  this.snapshot();
}

methods.hide = function(dim) {
  // append dim to currently hidden axes
  if(!Array.isArray(dim)) {
    dim = [dim];
  }

  // store brushExtents to reapply after render/updateAxes
  var extents = null;
  if(typeof(this.brushExtents) !== "undefined") {
    extents = this.brushExtents();
  }
  this.hideAxis(dim).render().updateAxes()
  if(extents) {
    this.brushExtents(extents);
  }
}

methods.unhide = function(dim) {
  // remove dim from currently hidden axes
  //  first convert dim to array if it is not one
  if(!Array.isArray(dim)) {
    dim = [dim];
  }
  var dims = this.hideAxis().filter(function(d) {dim.indexOf(d) !== -1});

  // store brushExtents to reapply after render/updateAxes
  var extents = null;
  if(typeof(this.brushExtents) !== "undefined") {
    extents = this.brushExtents();
  }
  this.hideAxis(dims).render().updateAxes()
  if(extents) {
    this.brushExtents(extents);
  }
}

export default methods;