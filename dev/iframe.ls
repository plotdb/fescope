# sample code for purpose of demonstrating how to use iframe to load script.
_load_iframe: (url) ->
  new Promise (res, rej) ~>
    loadscript = @_load_script.toString!
    # we need full url since iframe will load blob URL.
    full-url = if /(https?:)?\/\//.exec(url) => url
    else window.location.origin + (if url.0 == \/ => '' else \/) + url
    code = """
    <html><body><script type="text/javascript">
    function init() { rescope.load('#full-url').then(function() { rescope.onload(); })};
    </script></body></html>
    """
    src = URL.createObjectURL(new Blob([code], {type: \text/html}))
    node = document.createElement \iframe
    node.setAttribute \sandbox, ('allow-same-origin allow-scripts allow-pointer-lock allow-popups')
    node.style <<< opacity: 0, z-index: -1, pointer-events: \none
    node.onload = ~>
      node.contentWindow.rescope = do
        scope: scope = {}
        load: @_load_script
        onload: ~> res @scope[url] = scope[full-url]
      node.contentWindow.init!
    node.src = src
    document.body.appendChild node

