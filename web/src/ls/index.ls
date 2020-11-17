window.d3 = 'hi'
scope = new rescope {delegate: false, global: window}
scope.init!
  .then ->
    pkg = do
      lib: [
        \assets/lib/bootstrap.native/main/bootstrap-native.min.js
        \assets/lib/bootstrap.ldui/main/bootstrap.ldui.min.js
        {url: \assets/lib/@loadingio/ldquery/main/ldq.min.js, async: false}
        \assets/lib/ldcover/main/ldcv.min.js
        \assets/lib/ldview/main/ldview.min.js
        \js/functest.js
      ]

    d3pkg = do
      v3: \https://d3js.org/d3.v3.min.js
      v4: [
        {url: "https://d3js.org/d3.v4.js", async: false},
        "https://d3js.org/d3-format.v2.min.js",
        "https://d3js.org/d3-array.v2.min.js",
        "https://d3js.org/topojson.v2.min.js",
        {url: "https://d3js.org/d3-color.v1.min.js", async: false},
        {url: "https://d3js.org/d3-interpolate.v1.min.js", async: false},
        "https://d3js.org/d3-scale-chromatic.v1.min.js",
        "https://d3js.org/d3-dispatch.v2.min.js",
        "https://d3js.org/d3-quadtree.v2.min.js",
        "https://d3js.org/d3-timer.v2.min.js",
        "https://d3js.org/d3-force.v2.min.js"
      ]

    scope.peekScope!

    scope.load pkg.lib
      .then -> scope.context pkg.lib, -> it.functest!
      .then -> scope.load d3pkg.v3
      .then -> scope.load d3pkg.v4
      .then ->
        scope.context d3pkg.v3, -> 
          box = document.getElementById \d3v3 .getBoundingClientRect!
          d3.select \svg#d3v3 .selectAll \circle
            .data [0 to 100].map -> {x: Math.random!, y: Math.random!, r: Math.random!}
            .enter!append \circle
              .attr do
                cx: -> it.x * box.width
                cy: -> it.y * box.height
                r: -> it.r * 20
                fill: -> \#000
      .then ->
        scope.context d3pkg.v4, -> 
          box = document.getElementById \d3v4 .getBoundingClientRect!
          d3.select \svg#d3v4 .selectAll \circle
            .data [0 to 100].map -> {x: Math.random!, y: Math.random!, r: Math.random!}
            .enter!append \circle
              .attr \cx, -> it.x * box.width
              .attr \cy, -> it.y * box.height
              .attr \r, -> it.r * 20
              .attr \fill, -> \#000
