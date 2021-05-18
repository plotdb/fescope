libs = [
  {url: "https://d3js.org/d3.v4.js", async: false}
  {url: "https://d3js.org/d3-dispatch.v2.min.js", async: false}
  {url: "https://d3js.org/d3-selection.v2.min.js"}
  {url: "https://d3js.org/d3-transition.v2.min.js"}
  {url: "https://d3js.org/d3-format.v2.min.js"}
  {url: "https://d3js.org/d3-array.v2.min.js"}
  {url: "https://d3js.org/topojson.v2.min.js"}
  {url: "https://d3js.org/d3-color.v2.min.js"}
  {url: "https://d3js.org/d3-interpolate.v2.min.js", async: false}
  {url: "https://d3js.org/d3-scale-chromatic.v1.min.js"}
  {url: "https://d3js.org/d3-ease.v2.min.js"}
  {url: "https://d3js.org/d3-quadtree.v2.min.js"}
  {url: "https://d3js.org/d3-timer.v2.min.js"}
  {url: "https://d3js.org/d3-force.v2.min.js", async: false}
  {url: "https://d3js.org/d3-hierarchy.v2.min.js"}
  {url: "https://unpkg.com/d3-force-boundary@0.0.1/dist/d3-force-boundary.min.js"}
  {url: "https://d3js.org/d3-random.v2.min.js"}
  {url: "https://unpkg.com/ldcolor@0.0.3/dist/ldcolor.min.js"}
  {url: "https://d3js.org/d3-drag.v2.min.js",async: false}
  {url: "https://d3js.org/d3-brush.v2.min.js"}
  {url: "/assets/lib/@plotdb/pdmap-world/main/index.js"}
]

libs2 = [
  {url: "https://d3js.org/d3.v4.js", async: false}
  {url: "https://d3js.org/d3-array.v2.js"}
  {url: "https://d3js.org/d3-geo.v2.js"}
  #{url: "/assets/dev/d3-array.v2.js"}
  #{url: "/assets/dev/d3-geo.v2.js"}
]

/*
scope.init!
  .then -> scope.load libs
  .then (context) ->
    console.log context
    scope.context libs, ->
      svg = ld$.find 'svg', 0
      obj = new pdmap-world { root: svg }
      obj.init!then ~> obj.fit!
*/

wrapper = (code, context = []) ->
  ctx = {}
  for c in context => ctx <<< c
  _code = ""
  _code = ["var #k = ctx.#k;" for k,v of ctx].join(\\n) + \\n
  _code += """
  (function() {
    var global = this;
    var globalThis = this;
    var window = this;
    var self = this;
    #code
    return this;
  }).apply(ctx);
  """
  ret = eval _code
  return ret


rescope = (opt = {}) ->
  @

rescope.prototype = Object.create(Object.prototype) <<< do
  peekScope: ->
  init: -> Promise.resolve!
  context: (url, func) ->
    @load url .then (ctx) -> ret = func ctx[* - 1]
  load: (url) ->
    url = if Array.isArray(url) => url else [url]
    Promise.resolve!
      .then -> new Promise (res, rej) ->
        ctx = []
        _ = (list, idx = 0) ->
          if idx >= list.length => return res ctx
          url = (list[idx].url or list[idx])
          ld$.fetch url, {method: "GET"}, {type: \text}
            .then -> 
              c = wrapper it, ctx
              ctx.push c
            .then -> _ list, idx + 1
            .catch -> rej it
        _ url


scope = new rescope!

scope.load libs
  .then -> 
    console.log it
    {pdmap-world} = it[* - 1]
    svg = ld$.find 'svg', 0
    setTimeout (->
      obj = new pdmap-world { root: svg }
      obj.init!then ~> obj.fit!
    ), 1000
  .then ->
