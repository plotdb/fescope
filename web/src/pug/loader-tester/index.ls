scope = new rescope do
  registry: ({url, name, version, path}) -> url

load = ({url}) ->
  scope.load [{url}]
    .then (ctx) ->
      text = "success with:\n\n" + [" - #k" for k of ctx].join(\\n)
      view.get(\result).classList.toggle \border-danger, false
      view.get(\result).classList.toggle \text-danger, false
      view.get(\result).classList.toggle \text-success, true
      view.get(\result).classList.toggle \border-success, true
      view.get(\result).textContent = text
    .catch (e) ->
      view.get(\result).classList.toggle \border-danger, true
      view.get(\result).classList.toggle \text-danger, true
      view.get(\result).classList.toggle \text-success, false
      view.get(\result).classList.toggle \border-success, false
      view.get(\result).textContent = "error: \n\n" + e.toString!
      throw e

view = new ldview do
  root: document.body
  action: click:
    sample: ({node}) ->
      view.get(\url).value = node.dataset.url
      load url: view.get(\url).value
    load: ->
      if !(url = view.get(\url).value) => return
      load {url}
