rescope = (opt = {}) ->
  # in-frame: internal use. this rescope is used in iframe for collecting list of local variables.
  @opt = {in-frame: false} <<< opt
  @in-frame = !!@opt.in-frame
  @global = opt.global or if global? => global else window
  @scope = {}
  @

rescope.func = []

/*

window members. adopted from:
 - DOM: https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model
 - Properties: https://developer.mozilla.org/en-US/docs/Web/API/Window

used for list all un-enumerable attributes in window object.

*/

win-props =
  attr: <[
    applicationCache caches closed console controllers crossOriginIsolated crypto customElements
    defaultStatus devicePixelRatio dialogArguments directories document event frameElement frames
    fullScreen history indexedDB innerHeight innerWidth isSecureContext isSecureContext length
    localStorage location locationbar menubar mozAnimationStartTime mozInnerScreenX mozInnerScreenY
    mozPaintCount name navigator onabort onafterprint onanimationcancel onanimationend onanimationiteration
    onappinstalled onauxclick onbeforeinstallprompt onbeforeprint onbeforeunload onblur oncancel
    oncanplay oncanplaythrough onchange onclick onclose oncontextmenu oncuechange ondblclick
    ondevicemotion ondeviceorientation ondeviceorientationabsolute ondragdrop ondurationchange onended
    onerror onfocus onformdata ongamepadconnected ongamepaddisconnected ongotpointercapture onhashchange
    oninput oninvalid onkeydown onkeypress onkeyup onlanguagechange onload onloadeddata onloadedmetadata
    onloadend onloadstart onlostpointercapture onmessage onmessageerror onmousedown onmouseenter
    onmouseleave onmousemove onmouseout onmouseover onmouseup onmozbeforepaint onpaint onpause
    onplay onplaying onpointercancel onpointerdown onpointerenter onpointerleave onpointermove onpointerout
    onpointerover onpointerup onpopstate onrejectionhandled onreset onresize onscroll onselect
    onselectionchange onselectstart onstorage onsubmit ontouchcancel ontouchstart ontransitioncancel
    ontransitionend onunhandledrejection onunload onvrdisplayactivate onvrdisplayblur onvrdisplayconnect
    onvrdisplaydeactivate onvrdisplaydisconnect onvrdisplayfocus onvrdisplaypointerrestricted
    onvrdisplaypointerunrestricted onvrdisplaypresentchange onwheel opener origin outerHeight
    outerWidth pageXOffset pageYOffset parent performance personalbar pkcs11 screen screenLeft
    screenTop screenX screenY scrollbars scrollMaxX scrollMaxY scrollX scrollY self sessionStorage
    sidebar speechSynthesis status statusbar toolbar top visualViewport window Methods alert
    atob back blur btoa cancelAnimationFrame cancelIdleCallback captureEvents clearImmediate
    clearInterval clearTimeout close confirm convertPointFromNodeToPage convertPointFromPageToNode
    createImageBitmap dump fetch find focus forward getComputedStyle getDefaultComputedStyle
    getSelection home matchMedia minimize moveBy moveTo open openDialog postMessage
    print prompt queueMicrotask releaseEvents requestAnimationFrame requestFileSystem requestIdleCallback
    resizeBy resizeTo routeEvent scroll scrollBy scrollByLines scrollByPages
    scrollTo setCursor setImmediate setInterval setTimeout showDirectoryPicker showModalDialog
    showOpenFilePicker showSaveFilePicker sizeToContent stop updateCommands Events event
    afterprint animationcancel animationend animationiteration beforeprint beforeunload blur
    copy cut DOMContentLoaded error focus hashchange languagechange
    load message messageerror offline online orientationchange pagehide
    pageshow paste popstate rejectionhandled storage transitioncancel unhandledrejection
    unload vrdisplayconnect vrdisplaydisconnect vrdisplaypresentchange
  ]>

  dom: <[
    Attr CDATASection CharacterData ChildNode Comment CustomEvent Document
    DocumentFragment DocumentType DOMError DOMException DOMImplementation DOMString DOMTimeStamp
    DOMStringList DOMTokenList Element Event EventTarget HTMLCollection MutationObserver
    MutationRecord NamedNodeMap Node NodeFilter NodeIterator NodeList ProcessingInstruction
    Selection Range Text TextDecoder TextEncoder TimeRanges TreeWalker
    URL Window Worker XMLDocument
  ]>


rescope.prototype = Object.create(Object.prototype) <<< do
  peek-scope: -> console.log "in delegate iframe: #{!!@global._rescopeDelegate}"; return @global._rescopeDelegate
  init: ->
    if @in-frame => return Promise.resolve!
    # if we are in the host window, we need iframe to collect local variables
    new Promise (res, rej) ~>
      node = document.createElement \iframe
      node.setAttribute \name, "delegator-#{Math.random!toString(36)substring(2)}"
      node.setAttribute \sandbox, ('allow-same-origin allow-scripts')
      node.style <<< do
        opacity: 0, z-index: -1, pointer-events: \none, top: "0px", left: "0px"
        width: '0px', height: '0px', position: \absolute
      # `load` is exposed via contentWindow and used to load libs in sandbox.
      # it actually execute this object's load function so we keep it's scope in @frame-scope.
      code = """<html><body>
      <script>
      function init() {
        if(!window._scope) { window._scope = new rescope({inFrame:true,global:window}) }
      }
      function load(url,ctx) { return _scope.load(url,ctx); }
      function context(url,func) { _scope.context(url,func,true); }
      </script></body></html>"""
      node.onerror = -> rej it
      # pass this object to delegate so we can run it there.
      node.onload = ~>
        (@iframe = node.contentWindow) <<< {rescope: rescope, _rescopeDelegate: true}
        # use rescope from main window makes window related operations work on main window.
        # while we do restore window member variables, this may be a little disruptive
        # remove `rescope` and include rescope script with <script> can solve this issue.
        #(@iframe = node.contentWindow) <<< {_rescopeDelegate: true}
        @iframe.init!
        @frame-scope = @iframe._scope.scope
        win-props.all = Array.from(new Set([k for k of @iframe] ++ win-props.dom ++ win-props.attr))
        res!
      node.src = URL.createObjectURL(new Blob([code], {type: \text/html}))
      document.body.appendChild node

  # until-resolved: is this call for loading procedure?
  #   - we should always wait func returned promise to resolve, if it's loading procedure.
  #   - this should be lib only since it may lead strange behavior in concurrent contexts.
  context: (des, func, until-resolved = false) ->
    if typeof(des) == \string or Array.isArray(des) => @ctx-from-url des, func, until-resolved
    else @ctx-from-obj des, func, until-resolved

  # from-obj: we can load ctx directly from previous context object.
  ctx-from-obj: (context = {}, func, until-resolved = false) ->
    stack = {}
    for k of context =>
      stack[k] = @global[k]
      @global[k] = context[k]
    ret = func context
    # func may be `load` in rescope, and it is batched until a sync script is found.
    # we need to wait until it resolves otherwise its dependenies may fail.
    p = if until-resolved and ret and ret.then => ret else Promise.resolve!
    p.then ~>
      # context may be altered. must iterate stack.
      for k of stack => @global[k] = stack[k]

  # from-url: or, we provide a ( list of ) url, let rescope compose the context for us.
  ctx-from-url: (url, func, until-resolved = false) ->
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

  load: (url, ctx = {}) ->
    if !url => return Promise.resolve!
    ctx.{}local
    ctx.{}frame
    url = if Array.isArray(url) => url else [url]
    _ = ~>
      Promise.resolve!
        .then ~> if !@in-frame => @iframe.load(url, ctx)
        .then ~>
          _ = (list, idx = 0, ctx) ~>
            if idx >= list.length => return Promise.resolve ctx
            items = []
            for i from idx til list.length =>
              items.push list[i]
              if list[i].async? and !list[i].async => break
            if !items.length => return Promise.resolve ctx
            Promise.all(
              items.map ~>
                url = it.url or it
                @_load(url, ctx, @{}frame-scope[url])
            )
              .then ~>
                @context(
                  items.map(-> it.url or it),
                  ((c) ~>
                    ctx[if @in-frame => \frame else \local] <<< c
                    _(list, idx + items.length, ctx)
                  ),
                  true
                )
          _ url, 0, ctx
        .then ->

    if !ctx => return _!
    (res, rej) <~ new Promise _
    @context ctx[if @in-frame => \frame else \local], (~>
      _!then(-> res it)catch(->rej it)
    ), true

  _wrapper-alt: (url, code, context = {}, prescope = {}) -> new Promise (res, rej) ~>
    _code = ["var #k = context.#k;this.#k = context.#k;" for k,v of context].join(\\n) + \\n
    _postcode = ["if(typeof(#k) != 'undefined') { this.#k = #k; }" for k,v of prescope].join(\\n) + \\n
    # some libraries may access window directly.
    # note this may block access from lib to default window members.
    # but without this, library will fail when accessing dependencies directly via `window.xxx`.
    _force-scope = """
      /* intercept these variables so lib will inject anything into our scope */
      var global = this;
      var globalThis = this;
      var self = this;
      var window = this;
      /* yet we need window memebers so lib can work properly with builtin features */
      window.__proto__ = win;
      /* some props are not enumerable, so we list all of them directly in winProps.all */
      for(var i = 0; i < winProps.all.length; i++) {
        k = winProps.all[i];
        /* but functions need window as `this` to be called. we indirectly do this for them. */
        if(typeof(win[k]) == "function") {
          track.push(k);
          window[k] = (function(k){ return function() { return win[k].apply(win,arguments);} })(k);
        } else {
          /* and some members are from getter/setter. we proxy it via custom getter / setter object. */
          desc = Object.getOwnPropertyDescriptor(win,k);
          if(desc && desc.get) {
            track.push(k);
            Object.defineProperty(window, k, (function(n,desc) {
              var ret = {
                configurable: desc.configurable,
                enumerable: desc.enumerable
              };
              if(desc.get) { ret.get = function() { return win[n]; } }
              if(desc.set) { ret.set = function(it) { win[n] = it; } }
              return ret;
            }(k,desc)));
          }
        }
      }
    """
    id = "x" + Math.random!toString(36)substring(2)
    _code = """
    /* URL: #url */
    rescope.func.#id = function(context, winProps) {
      var win = window;
      var track = [];
      var ret = (function() {
        #_code
        #_force-scope
        #code
        #_postcode
        return this;
      }).apply({});
      /* returned ret may contain members from window through __proto__.  */
      /* we only need members from libs, so just ignore those from window object. */
      for(k in ret) {
        if((track.indexOf(k) == -1) && ret.hasOwnProperty(k)) { context[k] = ret[k]; }
      }
      return context;
    }
    """

    script = @global.document.createElement("script")
    hash = {}
    for k,v of @global => hash[k] = v
    script.onerror = ~> rej it
    script.onload = ~>
      @{}func[url] = rescope.func[id]
      res ({} <<< @{}func[url](context, win-props))
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

  _load: (url, ctx, prescope = {}) ->
    if @in-frame => return @_load-in-frame url
    ld$.fetch url, {method: "GET"}, {type: \text}
      .then (code) ~> @_wrapper-alt url, code, ctx.local, prescope
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
