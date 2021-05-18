libs = [
  {url: "https://d3js.org/d3.v4.js", async: false}
  {url: "https://d3js.org/topojson.v2.min.js"}
  {url: "/js/dev.js"}
  {url: "/assets/lib/@plotdb/pdmap-world/main/index.min.js"}
]
scope = new rescope!
scope.init!
  .then -> scope.load libs
  .then -> 
    scope.context libs, (context) ->
      context.devfunc!
      pdmap-world = context.pdmap-world
      svg = ld$.find 'svg', 0
      obj = new pdmap-world { root: svg }
      obj.init!then ~> obj.fit!
    /*
    {pdmap-world} = it[* - 1]
    svg = ld$.find 'svg', 0
    setTimeout (->
      obj = new pdmap-world { root: svg }
      obj.init!then ~> obj.fit!
    ), 1000
    */
  .then ->

