rsp = new rescope!
url = "/assets/dev/d3.v4.js"

bundle = ->
  rsp.bundle [url]
    .then -> ldfile.download data: it, name: "bundle.js"

loader = ->
  rsp.load url
    .then ->
      rsp.context url
    .then (ctx) ->
      console.log "1", ctx
      obj = rsp.cache url
      console.log "2", obj
      d3 = ctx.d3
      d3.selectAll \body
        .style \background, \#f00
