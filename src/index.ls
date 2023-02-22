var win, doc

_fetch = (u, c) ->
  if rsp.__node and fs? and !/^https:/.exec(u) =>
    return new Promise (res, rej) ->
      fs.read-file u, (e, b) -> if e => rej e else res b.toString!
  (ret) <- fetch u, c .then _
  if ret and ret.ok => return ret.text!
  if !ret => return Promise.reject(new Error("404") <<< {name: \lderror, id: 404})
  ret.clone!text!then (t) ->
    i = ret.status or 404
    e = new Error("#i #t") <<< {name: \lderror, id: i, message: t}
    try 
      if (j = JSON.parse(t)) and j.name == \lderror => e <<< j <<< {json: j}
    catch err
    return Promise.reject e

proxin = (o = {})->
  @lc = (o.context or {})
  @id = Math.random!toString(36)substring(2)
  if o.iframe => @iframe = o.iframe
  else
    @iframe = ifr = doc.createElement \iframe
    ifr.style <<< position: \absolute, top: 0, left: 0, width: 0, height: 0, pointerEvents: \none, opacity: 0
    ifr.setAttribute \title, "rescope script loader"
    ifr.setAttribute \name, "pdb-proxin-#{@id}"
    ifr.setAttribute \sandbox, ('allow-same-origin allow-scripts')
    doc.body.appendChild ifr
  attr = Object.fromEntries(Reflect.ownKeys(@iframe.contentWindow).map -> [it, true])
  func = {}
  @_proxy = new Proxy (o.target or win), do
    get: (t, k, o) ~>
      if @lc[k]? => return @lc[k]
      if func[k]? => return func[k]
      if typeof(t[k]) == \function => return func[k] = t[k].bind t
      if !attr[k]? => return undefined
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
  @iframe = ifr = doc.createElement \iframe
  @_cache = {}
  @proxy = new proxin!
  @registry(o.registry or "/assets/lib/")
  ifr.style <<< position: \absolute, top: 0, left: 0, width: 0, height: 0, pointerEvents: \none, opacity: 0
  ifr.setAttribute \title, "rescope script loader"
  ifr.setAttribute \name, "pdb-rescope-#{@id}"
  ifr.setAttribute \sandbox, ('allow-same-origin allow-scripts')
  doc.body.appendChild ifr
  ifr.contentWindow.document.body.innerHTML = (o.preloads or [])
    .map(-> """<script type="text/javascript" src="#it"></script>""").join('')
  @

rsp.env = -> [win, doc] := [it, it.document]
rsp.prop = legacy: {webkitStorageInfo: true}
rsp.id = (o) ->
  path = o.path or if o.type == \js => \index.min.js else if o.type == \css => \index.min.css else \index.html
  o.id or o.url or "#{if o.ns => "#{o.ns}:" else ''}#{o.name}@#{o.version or 'main'}:#path"
rsp._cache = {}
rsp._ver = {map: {}, list: {}}
rsp.cache = (o) ->
  if typeof(o) == \string => o = {url: o}
  if !o.id => o.id = rsp.id o
  if @_cache[o.id] => return that
  if o.id and !o.name =>
    k = o.id.split(':')
    if k.length <= 2 => [nv,p,s] = k else [s,nv,p] = k
    if !(ret = /^(@?[^@]+)(?:@([^:]+))?$/.exec(nv)) => ret = ['',o.id,'']
    n = ret.1
    v = ret.2
  else [s,n,v,p] = [o.ns, o.name, o.version or '', o.path or '']
  if /^[0-9.]+$/.exec v =>
    if @_ver.map{}[n][v] => v = that
    if @_cache[rsp.id({ns: s, name: n, version: v, path: p})] => return that
    for i from 0 til @_ver.list[][n].length =>
      ver = @_ver.list[n][i]
      if !semver.fit(ver, v) => continue
      @_ver.map[n][v] = ver
      o.id = rsp.id {ns: s, name: n, version: ver, path: p}
      if @_cache[o.id] => return that
  if !(v in @_ver.list[][n]) => @_ver.list[n].push v
  return @_cache[o.id] = o

rsp.prototype = Object.create(Object.prototype) <<<
  peek-scope: -> false # deprecated
  init: -> Promise.resolve! # deprecated

  _ref: (o) ->
    if typeof(o) == \string => o = {url: o}
    # promise from r(o) is deprecated. but if it is, url:r(o) is kinda weird. but ...
    if typeof(r = @_reg.url or @_reg) == \function => o = {} <<< o <<< {url: r o}
    # ... it will be return directly since then @_reg.fetch won't exist.
    return if @_reg.fetch => @_reg.fetch(o) else o.url

  registry: (v) ->
    if typeof(v) == \string =>
      if v[* - 1] == \/ => v = v.substring(0, v.length - 1)
      @_reg = ((v) -> (o) -> "#{v}/#{o.name}/#{o.version or 'main'}/#{o.path or 'index.min.js'}") v
    else @_reg = v

  cache: (o) -> 
    if typeof(o) == \string => o = {url: o}
    if !o.id => o.id = rsp.id o
    if @_cache[o.id] => return that
    return @_cache[o.id] = rsp.cache o

  exports: (o = {}) ->
    # TODO we should skip this step if all libs are loaded from bundle
    ctx = o.ctx or {}
    libs = if typeof(o.libs) == \string => [o.libs] else (o.libs or [])
    [hash, iw] = [{}, @iframe.contentWindow]
    for k of ctx => hash[k] = iw[k]; iw[k] = ctx[k]
    @_exports libs, 0, ctx
    for k of hash => iw[k] = hash[k]

  _exports: (libs, idx = 0, ctx = {}) ->
    if !(lib = libs[idx]) => return
    lib = @cache lib
    [hash, fprop, iw] = [{}, lib.fprop, @iframe.contentWindow]
    if !fprop =>
      lib <<< {fprop: fprop = {}, prop: {}, prop-initing: true}
      if lib.gen =>
        fprop <<< lib.gen.apply iw, [iw, iw, iw]
        lib.prop = Object.fromEntries [[k,null] for k of fprop]
      else
        att1 = Object.fromEntries(Reflect.ownKeys(iw).filter(->!rsp.prop.legacy[it]).map -> [it, true])
        for k of att1 => hash[k] = iw[k]
        # TODO use this to guarantee a global scope??
        # iw.run = function(code) { (new Function(code))(); }; iw.run(code);
        try
          iw.eval lib.code
        catch e
          console.error "[@plotdb/rescope] Parse failed", lib{url, ns, name, version, path}
          console.error "[@plotdb/rescope] with this error:", e
          throw e
        att2 = Object.fromEntries(Reflect.ownKeys(iw).filter(->!rsp.prop.legacy[it]).map -> [it, true])
        for k of att2 =>
          if iw[k] == hash[k] or (k in <[NaN]>) => continue
          fprop[k] = iw[k]
          # TODO how to determine if it's export only or loaded successfully?
          # may need additional flag
          lib.prop[k] = null
    else
      for k of fprop => hash[k] = iw[k]; iw[k] = fprop[k]
    for k of fprop => ctx[k] = fprop[k]
    @_exports libs, idx + 1
    for k of fprop => iw[k] = hash[k]
    # NOTE we can only retrieve synchronously assigned props.

  _wrap: (o = {}, ctx = {}, opt = {}) ->
    prop = o.prop or {}
    # NOTE 1: some libs may detect existency of themselves.
    #   so if we are using global scope, we will have to exclude them.
    #   however, since we scope everything in a isolated global, there is no need for this.
    # NOTE 2: some libs, such as setimmediate ( used by jszip), compare event source against `global`
    #   yet we overwrite `global` with our scope ( proxin ) object, thus this check will fail.
    code = """
    var window, global, globalThis, self, __ret = {}; __win = {};
    window = global = globalThis = self = window = scope;
    """
    # some libs may still access window directly ( perhaps via (function() { var window = this; })();
    # so we store original win[k] in __win, and restore them later.
    for k of prop => code += "var #k; __win['#k'] = win['#k']; win['#k'] = undefined;"
    for k of ctx => code += "var #k = window['#k'] = ctx['#k'];"
    code += "#{o.code};"
    for k of prop =>
      # either local variable, fake window obj, real window obj
      #   or possibly `this` variable if some libs use `this` as window object. ( yes, bad practice )
      # some libs may update global.k, but access variable k. in this case, k will undefined
      #   so we have to update k if it's undefined. ( the `if(!(k)) { ... }` code )
      code += """
      if(!(#k)) { #k = scope['#k']; }
      __ret['#k'] = #k || window['#k'] || win['#k'] || this['#k'];
      win['#k'] = __win['#k'];
      """
    code += "return __ret;"
    if opt.code-only => return "function(scope, ctx, win){#code}"
    return new Function("scope", "ctx", "win", code)

  # force-fetch: always refetch data
  # only-fetch: totally ignore updating ctx part. for bundling.
  load: (libs, dctx = {}, force-fetch = false, only-fetch = false) ->
    libs = (if Array.isArray(libs) => libs else [libs]).map (o) ~> @cache o
    # store px in libs and create on load, otherwise different libs will intervene each other
    # TODO should we wrap libs in some kind of object so we can keep their state?
    px = if libs.px => libs.px else libs.px = (if dctx and dctx.p => dctx.p else new proxin!)
    ctx = px.ctx!
    proxy = px.proxy!

    /*
    # this tries to segment libs based on async flag.
    # however, current implementation batches fetches and then loads by order
    # in this case segment seems to be unnecessary.
    # we will keep the code here for reference.
    [segs, seg] = [[], []]
    for lib in libs =>
      seg.push lib
      if !(lib.async? and !lib.async) => continue
      segs.push seg
      seg = []
    if seg.length => segs.push seg
    */
    segs = [libs]

    _ = (idx = 0) ~>
      if !(libs = segs[idx]) => return Promise.resolve(ctx)
      ps = libs.map (lib) ~>
        if (lib.code or lib.gen) and !force-fetch => return Promise.resolve!
        ref = @_ref(lib)
        if ref.then => ref.then ~>
          lib.code = it.content
          @cache(lib <<< {id: undefined, version: it.version, code: it.content})
        else _fetch ref, {method: \GET} .then -> lib.code = it
      Promise.all ps
        .then ~>
          if only-fetch => return
          # TODO to optimizing, we may need some way to skip this if libs are bundled and preloaded.
          @exports {libs, ctx: dctx.f}
          libs.map (lib) ~>
            if lib.prop-initing =>
              if !lib.gen => lib.gen = @_wrap lib, ctx
              lib.prop = lib.gen.apply proxy, [proxy, ctx, win]
              lib.prop-initing = false
            ctx <<< lib.prop
        .then ~> ctx
        .then ~> _ idx + 1
    _ 0

  context: (libs, func, px) ->
    if typeof(func) != \function => [func, px] = [px, func]
    @load libs, px .then (ctx) -> if func => func ctx else return ctx

rsp.env if self? => self else globalThis
rsp.proxin = proxin

# for creating empty context of both main window and iframe, so we call it `dual-context`.
#  - `p`: proxy ( for main window )
#  - `f`: context object for iframe
#  - `ctx()`: get context from main window
rsp.dual-context = -> {p: new proxin!, f: {}, ctx: -> @p.ctx!}
