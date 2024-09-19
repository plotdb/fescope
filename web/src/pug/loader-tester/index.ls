scope = new rescope do
  registry: ({url, name, version, path}) -> url

view = new ldview do
  root: document.body
  action: click: load: ->
    if !(url = view.get(\url).value) => return
    scope.load [{url}]
      .then (ctx) ->
        text = "success with:\n\n" + [" - #k" for k of ctx].join(\\n)
        view.get(\result).classList.toggle \border-danger, false
        view.get(\result).classList.toggle \text-danger, false
        view.get(\result).classList.toggle \text-success, true
        view.get(\result).classList.toggle \border-success, true
        view.get(\result).textContent = text
      .catch (e) ->
        console.log \ok123
        view.get(\result).classList.toggle \border-danger, true
        view.get(\result).classList.toggle \text-danger, true
        view.get(\result).classList.toggle \text-success, false
        view.get(\result).classList.toggle \border-success, false
        view.get(\result).textContent = "error: \n\n" + e.toString!

