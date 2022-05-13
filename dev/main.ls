require! <[jsdom]>
rescope = require "../dist/index"
dom = new jsdom.JSDOM('', {url: "http://localhost"})
rescope.env dom.window
rsp = new rescope({
  registry: ({name, version, path}) -> "https://cdn.jsdelivr.net/npm/#{name}@#{version}/#{path or ''}"
})


rsp.load [{name: 'ldview', version: '1.1.1', path: "index.min.js"}]
  .then (ctx) -> console.log ctx
