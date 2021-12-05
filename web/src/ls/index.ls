# d3 check for window.d3 before initing so we should never do things like this:
# window.d3 = 'hi'

scope = new rescope {global: window}

# following is the sample code for fake rescope
# it's possible to totally ignore the whole scope thing and use window as scope
# this merge all scopes into one so things may not work as expected.
if use-fakescope? and use-fakescope =>
  console.log " - use fakescope: true "
  scope =
    init: -> Promise.resolve!
    peekScope: -> Promise.resolve!
    load: -> Promise.resolve!
    context: (lib, cb) -> Promise.resolve cb(window)

scope.init!
  .then ->
    pkg = do
      lib: [
        \assets/lib/bootstrap.native/main/bootstrap-native.min.js
        \assets/lib/bootstrap.ldui/main/bootstrap.ldui.min.js
        {url: \assets/lib/@loadingio/ldquery/main/ldq.min.js, async: false}
        \assets/lib/ldcover/main/index.min.js
        \assets/lib/ldview/main/index.min.js
        \js/functest.js
      ]

    d3pkg = do
      v3: \/assets/dev/d3.v3.js
      v4: [
        {url: "/assets/dev/d3.v4.js", async: false},
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
      .then -> scope.context pkg.lib, ({functest}) -> functest!
      .then -> scope.load d3pkg.v3
      .then -> scope.load d3pkg.v4
      .then ->
        scope.context d3pkg.v3, ({d3}) ->
          console.log "[d3 v3]", d3.version
          box = document.getElementById \d3v3 .getBoundingClientRect!
          d3.select \svg#d3v3 .selectAll \circle
            .data [0 to 100].map -> {x: Math.random!, y: Math.random!, r: Math.random!}
            .enter!append \circle
              # new syntax
              .attr \cx, -> it.x * box.width
              .attr \cy, -> it.y * box.height
              .attr \r, -> it.r * 20
              .attr \fill, -> \#000
              # old syntax
              /*
              .attr do
                cx: -> it.x * box.width
                cy: -> it.y * box.height
                r: -> it.r * 20
                fill: -> \#000
              */

        debounce 1
      .then ->
        scope.context d3pkg.v4, ({d3}) ->
          console.log "[d3 v4]", d3.version
          box = document.getElementById \d3v4 .getBoundingClientRect!
          d3.select \svg#d3v4 .selectAll \circle
            .data [0 to 100].map -> {x: Math.random!, y: Math.random!, r: Math.random!}
            .enter!append \circle
              .attr \cx, -> it.x * box.width
              .attr \cy, -> it.y * box.height
              .attr \r, -> it.r * 20
              .attr \fill, -> \#000

