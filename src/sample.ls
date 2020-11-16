
lm = new felib!

module = do
  lib: [
    {url: "https://d3js.org/d3.v4.js", async: false},
    "https://d3js.org/d3-format.v2.min.js",
    "https://d3js.org/d3-array.v2.min.js",
    "https://d3js.org/topojson.v2.min.js",
    {url: "https://d3js.org/d3-color.v1.min.js", async: false},
    "https://d3js.org/d3-interpolate.v1.min.js",
    "https://d3js.org/d3-scale-chromatic.v1.min.js",
    "https://d3js.org/d3-dispatch.v2.min.js",
    "https://d3js.org/d3-quadtree.v2.min.js",
    "https://d3js.org/d3-timer.v2.min.js",
    "https://d3js.org/d3-force.v2.min.js",
  ]

lm.load module.lib
  .then -> console.log 'loaded', it

/*
lm.load 'https://d3js.org/d3.v6.min.js'
  .then ->
    lm.load '/js/test.js'
  .then -> 
    lm.context 'https://d3js.org/d3.v6.min.js', ->
      console.log d3
      lm.load '/js/test2.js'
        .then ->
          console.log it
          lm.context '/js/test.js', ->
            lm.context '/js/test2.js', ->
              console.log testObj, test2Obj
            console.log testObj, test2Obj
          console.log testObj, test2Obj
        .then ->
          lm.context <[/js/test.js /js/test2.js]>, -> console.log testObj, test2Obj
*/
