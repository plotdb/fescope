fescope = ->
  @scope = {}
  @

fescope.prototype = Object.create(Object.prototype) <<< do
  context: (url, func) ->
    url = if Array.isArray(url) => url else [url]
    stacks = []
    scopes = []
    for i from 0 til url.length =>
      [stack,scope] = [{}, @scope[url[i].url or url[i]] or {}]
      for k of scope =>
        stack[k] = window[k]
        window[k] = scope[k]
      stacks.push stack
      scopes.push scope

    func!
    for i from scopes.length - 1 to 0 by -1
      scope = scopes[i]
      stack = stacks[i]
      for k of scope => window[k] = stack[k]

  load: (url) ->
    if !url => return Promise.resolve!
    url = if Array.isArray(url) => url else [url]
    ret = {}
    new Promise (res, rej) ~> 
      _ = (list, idx) ~>
        items = []
        if idx >= list.length => return res ret
        for i from idx til list.length =>
          items.push list[i]
          if list[i].async? and !list[i].async => break

        if !items.length => return res ret

        Promise.all(items.map ~> @_load(it.url or it).then ~> ret <<< it)
          .then ~> @context items.map(-> it.url or it), -> _(list, idx + items.length)

      _ url, 0

  _load: (url) ->
    new Promise (res, rej) ~>
      script = document.createElement("script")
      hash = {}
      for k,v of window => hash[k] = v
      script.onerror = ~> rej!
      script.onload = ~>
        @scope[url] = scope = {}
        for k,v of window =>
          if hash[k]? or !(window[k]?) => continue
          scope[k] = window[k]
          # TODO how about if k already exists before script load?
          window[k] = undefined
        res scope
      script.setAttribute \src, url
      document.body.appendChild script

if module? => module.exports = fescope
if window? => window.fescope = fescope
