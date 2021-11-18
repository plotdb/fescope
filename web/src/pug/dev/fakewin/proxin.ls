
proxin = ->
  @hash = {}
  @proxy = new Proxy window, do
    set: (t, k, v) ~>
      console.log "proxy.set: ", k
      if !@hash[k] => @hash[k] = t[k]
      t[k] = v
      return true
  @

proxin <<<
  func: {}

proxin.prototype = Object.create(Object.prototype) <<<
  enter: ->
    wind
  wrap: (code) ->
    @id = Math.random!toString(16)substring(2)
    code = """
    proxin.func["#{@id}"] = pp = function(proxy) {
    console.log(1);
    /*
    var global = proxy; 
    var globalThis = proxy; 
    var self = proxy; 
    var window = proxy; 
    */
    console.log(2);
    #code
    console.log(3);
    };
    pp(document.currentScript.proxy);
    """
    node = document.createElement \script
    node.proxy = @proxy
    node.onerror = ->
    console.log \a
    node.onload = ~>
      console.log \onload
      proxin.func[@id](@proxy)
    node.appendChild document.createTextNode(code)
    console.log \b
    document.body.appendChild node

  restore: ->
    for k,v of @hash => window[k] = v

window.proxin = proxin
