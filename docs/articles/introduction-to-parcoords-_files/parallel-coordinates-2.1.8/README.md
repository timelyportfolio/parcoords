# parcoords-es

ES6 module of Syntagmatic's [Parallel Coordinates](https://github.com/syntagmatic/parallel-coordinates) (aka. parcoords). This library is completely based on D3 V5 API. 


## Features

Please refer to [Parallel Coordinates](https://github.com/syntagmatic/parallel-coordinates)'s project page for concepts and API usage

All examples of the original project has been verified. You can play with them via running:
 
```
npm install
npm run dev
```

## API
This section only lists api that are <b>deviated</b> from the original parallel coordinates.


<a name="parcoords_brush_extents" href="#parcoords_brush_extents">#</a> <b>brushExtents</b> supports 1D multi brushes:

1D brush [<>](https://github.com/BigFatDog/parcoords-es/blob/master/demo/setterForBrushes.html "Source")
```javascript
  .brushMode("1D-axes")
  .brushExtents({"2": [3,4]});
```

1D multi brush [<>](https://github.com/BigFatDog/parcoords-es/blob/master/demo/setterForMultiBrushes.html "Source")
```javascript
  .brushMode("1D-axes-multi")
  .brushExtents({"2": [[3,4], [6,8], [10, 14]]});

```

<a name="parcoords_marking" href="#parcoords_marking">#</a> parcoords.<b>mark</b>([values])
allows user to permanently highlight a data element in chart
```
const data = [...];
const pc = ParCoords().data(data)...;
parcoords.mark(data.filter(d => d.volume > 10));
```
Please refer to [marking demo](https://github.com/BigFatDog/parcoords-es/blob/develop/demo/marking.html "Source") for details

<a name="parcoords_unmark" href="#parcoords_unmark">#</a> parcoords.<b>unmark</b>()
clears all permanently highlighted data that is added by <a href="#parcoords_marking">mark([values])</a>

<a name="parcoords_brush_arg" href="parcoords_brush_arg">#</a> parccords.<b>on</b>(function(brushed, args){})
adds brush arguments to `brushstart`, `brush`, and `brushend` events.

```
parcoords.on('brushstart', function(brushed, args){
    const {
        selection: {
            raw, //raw coordinate
            scaled //y-scale transformed
        },
        node, // svg node
        axis // dimension name
    } = args;
})
```
Please refer to [brushing with arguments demo](https://github.com/BigFatDog/parcoords-es/blob/develop/demo/brush-with-arguments.html "Source") for details

## Usage

### ES6
1. Install library in your project
```
npm install parcoord-es --save
```

2. import module

```
import 'parcoord-es/parcoords.css';
import ParCoords from 'parcoord-es';

const chart = ParCoords()....
```
### Standalone

parcoords.standalone.js contains all dependencies and can be used directly in your html page. Please note that only essential D3 V5 modules are bundled, your global namespace won't be polluted.
```
<link rel="stylesheet" type="text/css" href="./parcoords.css">
<script src="./parcoords.standalone.js"></script>

var parcoords = ParCoords()("#example")
```

You are free to use either D3 V3 or D3 V5 in your html. demo/superformula.html demonstrates how to use parcoords-es with d3 V3.

## Development

Follow this instruction to setup development environment for parcoords-es
### Prerequisites

npm


### Installing


```
npm install
```

### Building

```
npm run build
```
### Development
Internal server will be launched, hosting all demos at localhost:3004

```
npm run dev
```

### Testing (Coverage)
run all unit tests and generate test coverage report.

```
npm run test:cover
```

## Built With

* [D3 V5](https://d3js.org/) - D3 modules are used
* [Rollup](https://github.com/rollup/rollup) - Module bundler


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Contributors
This project gets supports from open-source community. Many thanks to our [contributors](https://github.com/BigFatDog/parcoords-es/graphs/contributors)

## Acknowledgments
This project is based on [Parallel Coordinates](https://github.com/syntagmatic/parallel-coordinates) v0.7.0. Many thanks to [parcoords contributors](https://github.com/syntagmatic/parallel-coordinates/graphs/contributors) for such a complicated and useful D3 visualization.
