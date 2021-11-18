iframe = document.createElement \iframe
document.body.appendChild iframe
iframe = iframe.contentWindow
props =
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
props.all = props.dom ++ props.attr

ra = iframe.innerHeight
missed = []
byof = [k for k of iframe]
byof.sort (a,b) -> if a < b => -1 else if a > b => 1 else 0
for k in props.all =>
  if !~byof.indexOf(k) => missed.push k
console.log "missed: #{missed.length} / #{props.all.length}"
console.log byof
/*
for k in byof =>
  if !~props.all.indexOf(k) => missed.push k
console.log "missed: #{missed.length} / #{byof.length}"
*/

fakewin = (w, props) ->
  # builtin window memebers 
  fake = {__proto__: w}
  # list of members in fake
  track = []
  list = [k for k of fake]
  list.sort (a,b) -> if a < b => -1 else if a > b => 1 else 0
  # some props are not enumerable, so we list all of them directly in props.all
  /*
  for k in props.all =>
    # but functions need window as `this` to be called. we indirectly do this for them.
    if typeof(w[k]) == \function => fake[k] = ((k) -> -> w[k].apply w, arguments)(k)
    else
      # some members are from getter/setter. we proxy it via custom getter / setter object.
      if !(dsc = Object.getOwnPropertyDescriptor(w,k)) and dsc.get => continue
      Object.defineProperty(fake, k, ((n,dsc) ->
        ret = { configurable: dsc.configurable, enumerable: dsc.enumerable }
        if dsc.get => ret.get = -> w[n]
        if dsc.set => ret.set = -> w[n] = it
        return ret
      )(k,dsc))
    track.push k
  */
  return {fake, track, list}

{fake, trac, list} = fakewin window, {}
#console.log fake, list
/*
parse = (win) ->
  global = globalThis = self = window = @
  window.__proto__ = win

func = ((context) ->
  win = window
  ret = (-> parse.apply(@, [win]);return @).apply({})
  return context
)
*/
