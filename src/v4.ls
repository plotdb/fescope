# rescope v4
/*
lib spec
  id: from `rescope.id`
  url, name, version, path
  prop
  code: source code for this library.

declarative version ( used in dependency declaration )
  url, name, version, path, ..?
*/

_fetch = (url, cfg) ->
  (ret) <- fetch url, cfg .then _
  if ret and ret.ok => return ret.text!
  if !ret => return Promise.reject(new Error("404") <<< {name: \lderror, id: 404})
  ret.clone!text!then (t) ->
    i = ret.status or 404
    e = new Error("#i #t") <<< {name: \lderror, id: i, message: t}
    try 
      if (j = JSON.parse(t)) and j.name == \lderror => e <<< j <<< {json: j}
    catch er
    return Promise.reject e

proxin = (o = {})->
  @lc = (o.context or {})
  @id = Math.random!toString(36)substring(2)
  if o.iframe => @iframe = o.iframe
  else
    @iframe = ifr = document.createElement \iframe
    ifr.style <<< position: \absolute, top: 0, left: 0, width: 0, height: 0, pointerEvents: \none, opacity: 0
    ifr.setAttribute \title, "rescope script loader"
    ifr.setAttribute \name, "pdb-proxin-#{@id}"
    ifr.setAttribute \sandbox, ('allow-same-origin allow-scripts')
    document.body.appendChild ifr
  attr = Object.fromEntries(Reflect.ownKeys(@iframe.contentWindow).map -> [it, true])
  func = {}
  @_proxy = new Proxy (o.target or window), do
    get: (t, k, o) ~>
      if @lc[k]? => return @lc[k]
      if func[k]? => return func[k]
      if !attr[k]? => return undefined
      if typeof(t[k]) == \function => return func[k] = t[k].bind t
      return t[k]
    set: (t, k, v) ~>
      if attr[k] =>
        t[k] = v
        return true
      @lc[k] = v
      return true
  @

proxin.prototype = Object.create(Object.prototype) <<<
  proxy: -> @_proxy
  ctx: -> @lc

rsp = (o = {}) ->
  @id = Math.random!toString(36)substring(2)
  @iframe = ifr = document.createElement \iframe
  @_cache = {}
  @proxy = new proxin!
  @registry(o.registry or "/assets/lib/")
  ifr.style <<< position: \absolute, top: 0, left: 0, width: 0, height: 0, pointerEvents: \none, opacity: 0
  ifr.setAttribute \title, "rescope script loader"
  ifr.setAttribute \name, "pdb-rescope-#{@id}"
  ifr.setAttribute \sandbox, ('allow-same-origin allow-scripts')
  document.body.appendChild ifr
  ifr.contentWindow.document.body.innerHTML = (o.preloads or [])
    .map(-> """<script type="text/javascript" src="#it"></script>""").join('')
  @

rsp.prop = legacy: {webkitStorageInfo: true}
rsp.id = (o) -> o.id or o.url or "#{o.name}@#{o.version}/#{o.path}"
rsp._cache = {}
rsp.cache = (o) ->
  if typeof(o) == \string => o = {url: o}
  if !o.id => o.id = rsp.id o
  if r = rsp._cache[o.id] => return r
  return rsp._cache[o.id] = {} <<< o

# TODO prebundle mechanism
rsp.bundle = (o = {}) ->
  o = {} <<< o
  if !o.id => o.id = rsp.id o

rsp.prototype = Object.create(Object.prototype) <<<
  _url: (o) ->
    return if typeof(o) == \string => o
    else if o.url => that
    else @_reg o

  registry: (v) ->
    if typeof(v) == \string =>
      if v[* - 1] == \/ => v = v.substring(0, v.length - 1)
      @_reg = ((v) -> (o) -> "#{v}/#{o.name}/#{o.version or 'main'}/#{o.path or 'index.min.js'}") v
    else @_reg = v

  cache: (o) -> 
    if typeof(o) == \string => o = {url: o}
    if !o.id => o.id = rsp.id o
    if r = @_cache[o.id] => return r
    if rsp._cache[o.id] => return @_cache[o.id] = that
    return @_cache[o.id] = {} <<< o

  exports: (o = {}) ->
    ctx = o.ctx or {}
    libs = if typeof(o.libs) == \string => [o.libs] else (o.libs or [])
    [hash, iw] = [{}, @iframe.contentWindow]
    for k of ctx => hash[k] = iw[k]; iw[k] = ctx[k]
    @_exports libs, 0
    for k of ctx => iw[k] = hash[k]

  _exports: (libs, idx = 0) ->
    if !(lib = libs[idx]) => return
    lib = @cache lib
    [hash, fprop, iw] = [{}, lib.fprop, @iframe.contentWindow]
    if !fprop =>
      lib <<< {fprop: fprop = {}, prop: {}}
      att1 = Object.fromEntries(Reflect.ownKeys(iw).filter(->!rsp.prop.legacy[it]).map -> [it, true])
      for k of att1 => hash[k] = iw[k]
      # TODO use this to guarantee a global scope??
      # iw.run = function(code) { (new Function(code))(); }; iw.run(code);
      iw.eval lib.code
      att2 = Object.fromEntries(Reflect.ownKeys(iw).filter(->!rsp.prop.legacy[it]).map -> [it, true])
      for k of att2 =>
        if iw[k] == hash[k] or (k in <[NaN]>) => continue
        fprop[k] = iw[k]
        # TODO how to determine if it's export only or loaded successfully?
        # may need additional flag
        lib.prop[k] = null
        lib.prop-initing = true
    else
      for k of fprop => hash[k] = iw[k]; iw[k] = fprop[k]
    @_exports libs, idx + 1
    for k of fprop => iw[k] = hash[k]
    # NOTE we can only retrieve synchronously assigned props.

  _wrap: (o = {}, ctx = {}) ->
    ctx-id = [k for k of ctx].join(',')
    prop = o.prop or {}
    # NOTE: some libs may detect existency of themselves.
    # so if we are using global scope, we will have to exclude them.
    # however, since we scope everthing in a isolated global, there is no need for this.
    code = """
    var window, global, globalThis, self, __ret = {};
    window = global = globalThis = window = scope;
    """
    for k of prop => code += "var #k;"
    for k of ctx => code += "var #k = window['#k'] = ctx['#k'];"
    code += "#{o.code};"
    for k of prop => code += "__ret['#k'] = #k || window['#k'];"
    code += "return __ret;"
    return new Function("scope", "ctx", code)

  load: (libs, proxy) ->
    libs = (if Array.isArray(libs) => libs else [libs]).map (lib) ~> @cache lib
    ctx = (proxy or @proxy).ctx!
    proxy = (proxy or @proxy).proxy!
    ps = libs.map (lib) ~>
      if lib.code => return Promise.resolve!
      ld$.fetch @_url(lib), {method: \GET}, {type: \text}
        .then (code) -> lib.code = code # TODO: also accept parsed function such as `gen`
    Promise.all ps
      .then ~>
        @exports {libs}
        libs.map (lib) ~>
          if lib.prop-initing =>
            lib.gen = @_wrap lib, ctx
            lib.prop = lib.gen proxy, ctx
            lib.prop-initing = false
          ctx <<< lib.prop
      .then ~> ctx

  context: (libs, func, proxy) ->
    @load libs, proxy .then (ctx) -> func ctx

if module? => module.exports = rsp
else if window => window.rescope = rsp
