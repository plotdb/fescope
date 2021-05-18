rescope = (opt = {}) ->
  # in-frame: internal use. this rescope is used in iframe for collecting list of local variables.
  @opt = {in-frame: false} <<< opt
  @in-frame = @opt.in-frame
  @global = opt.global or if global? => global else window
  @scope = {}
  @

rescope.func = []

rescope.prototype = Object.create(Object.prototype) <<< do
  peek-scope: -> console.log "in delegate iframe: #{!!@global._rescopeDelegate}"; return @global._rescopeDelegate
  init: ->
    if @in-frame => return Promise.resolve!
    # if we are in the host window, we need iframe to collect local variables
    new Promise (res, rej) ~>
      node = document.createElement \iframe
      node.setAttribute \name, "delegator-#{Math.random!toString(36)substring(2)}"
      node.setAttribute \sandbox, ('allow-same-origin allow-scripts')
      node.style <<< opacity: 0, z-index: -1, pointer-events: \none, width: '0px', height: '0px'
      # `load` is exposed via contentWindow and used to load libs in sandbox.
      # it actually execute this object's load function so we keep it's scope in @frame-scope.
      code = """<html><body><script>
      function init() {
        if(!window._scope) { window._scope = new rescope({inFrame:true,global:window}) }
      }
      function load(url) { return _scope.load(url); }
      function context(url,func) { _scope.context(url,func,true); }
      </script></body></html>"""
      node.onerror = -> rej it
      # pass this object to delegate so we can run it there.
      node.onload = ~>
        (@iframe = node.contentWindow) <<< {rescope: rescope, _rescopeDelegate: true}
        @iframe.init!
        @frame-scope = @iframe._scope.scope
        res!
      node.src = URL.createObjectURL(new Blob([code], {type: \text/html}))
      document.body.appendChild node

  # until-resolved: is this call for loading procedure?
  #   - we should always wait func returned promise to resolve, if it's loading procedure.
  #   - this should be lib only since it may lead strange behavior in concurrent contexts.
  context: (url, func, until-resolved = false) ->
    url = if Array.isArray(url) => url else [url]
    stacks = []
    scopes = []
    context = {}
    for i from 0 til url.length =>
      [stack,scope] = [{}, @scope[url[i].url or url[i]] or {}]
      for k of scope =>
        stack[k] = @global[k]
        @global[k] = scope[k]
        context[k] = scope[k]
      stacks.push stack
      scopes.push scope
    ret = func context

    # func may be `load` in rescope, and it is batched until a sync script is found.
    # we need to wait until it resolves otherwise its dependenies may fail.
    p = if until-resolved and ret and ret.then => ret else Promise.resolve!
    p.then ~>
      for i from scopes.length - 1 to 0 by -1
        scope = scopes[i]
        stack = stacks[i]
        for k of scope => @global[k] = stack[k]

  load: (url) ->
    if !url => return Promise.resolve!
    url = if Array.isArray(url) => url else [url]
    Promise.resolve!
      .then ~> if !@in-frame => @iframe.load(url)
      .then ~> new Promise (res, rej) ~>
        _ = (list, idx = 0, ctx = {}) ~>
          if idx >= list.length => return res ctx
          items = []
          for i from idx til list.length =>
            items.push list[i]
            if list[i].async? and !list[i].async => break
          if !items.length => return res ctx

          Promise.all(
            items.map ~>
              url = it.url or it
              @_load(url, ctx, @{}frame-scope[url])
          )
            .then ~>
              @context(
                items.map(-> it.url or it),
                ((c) -> _(list, idx + items.length, (ctx <<< c))),
                true
              )
            .catch -> rej it
        _ url, 0

  _wrapper-alt: (url, code, context = {}, prescope = {}) -> new Promise (res, rej) ~> 
    _code = ""
    _code = ["var #k = context.#k;" for k,v of context].join(\\n) + \\n
    _postcode = ["if(typeof(#k) != 'undefined') { this.#k = #k; }" for k,v of prescope].join(\\n) + \\n
    _force-scope = """
      var global = this;
      var globalThis = this;
      var window = this;
      var self = this;
    """
    _force-scope = ""
    id = "x" + Math.random!toString(36)substring(2)
    _code = """
    /* URL: #url */
    rescope.func.#id = function(context) {
      return (function() {
        #_code
        #_force-scope
        #code
        #_postcode
        return this;
      }).apply(context);
    }
    """

    script = @global.document.createElement("script")
    hash = {}
    for k,v of @global => hash[k] = v
    script.onerror = ~> rej it
    script.onload = ~>
      @{}func[url] = rescope.func[id]
      res ({} <<< @{}func[url](context))
    script.setAttribute \src, URL.createObjectURL(new Blob([_code], {type: \text/javascript}))
    @global.document.body.appendChild script

  _wrapper: (url, code, context = {}, prescope = {}) ->
    _code = ""
    _code = ["var #k = context.#k;" for k,v of context].join(\\n) + \\n
    _postcode = ["if(typeof(#k) != 'undefined') { this.#k = #k; }" for k,v of prescope].join(\\n) + \\n
    _force-scope = """
      var global = this;
      var globalThis = this;
      var window = this;
      var self = this;
    """
    _force-scope = ""
    _code = """
    (function() {
      #_code
      #_force-scope
      #code
      #_postcode
      return this;
    }).apply(context);
    """
    ret = eval _code
    return {} <<< ret

  _load: (url, ctx = {}, prescope = {}) ->
    if @in-frame => return @_load-in-frame url
    ld$.fetch url, {method: "GET"}, {type: \text}
      .then (code) ~> @_wrapper-alt url, code, ctx, prescope
      .then (c) ~> @scope[url] = c


  _load-in-frame: (url) -> new Promise (res, rej) ~> 
    script = @global.document.createElement("script")
    hash = {}
    for k,v of @global => hash[k] = v
    script.onerror = ~> rej it
    script.onload = ~>
      # if we have @scope - it either is load twice, or is from delegate.
      # we can simply adopt the calculated scope members, and copy them from vars loaded in host.
      if @scope[url] =>
        scope = @scope[url]
        for k,v of scope =>
          scope[k] = @global[k]
          @global[k] = hash[k]
      else
        @scope[url] = scope = {}
        for k,v of @global =>
          # treat `k` as imported var if:
          # A. `k` changed.
          # if (hash[k]? and hash[k] == @global[k]) or !(@global[k]?) => continue
          # B. `k` added. can't detect/restore overwritten object.
          #    however in delegate this should be okay.
          if hash[k]? or !(@global[k]?) => continue
          # if host script touches window object, both A. and B. might give incorrect result.
          # thus, we always use delegate to load, but run with context of host.
          scope[k] = @global[k]
          @global[k] = hash[k]
      res scope
    # we might in iframe sandbox run in blob URL. so we have to use absolute URL.
    full-url = if /(https?:)?\/\//.exec(url) => url
    else window.location.origin + (if url.0 == \/ => '' else \/) + url
    script.setAttribute \src, full-url
    @global.document.body.appendChild script

if module? => module.exports = rescope
if window? => window.rescope = rescope
