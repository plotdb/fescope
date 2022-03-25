# this dummy rescope install every cached modules into window directly.
# currently this is only for evaluation.

rsp = -> @
rsp.cache = (o) -> window.eval(o.code)
rsp.prototype = Object.create(Object.prototype) <<< do
  init: ->
  registry: ->
  load: (libs, dctx = {}) ->
    dctx <<< window
    # only install specific libs:
    # dctx <<< window{ld$, ldcolor, ldcolorpicker, ldcvmgr, ldpp, ldslider, ldcover, ldloader, zmgr, ldview}
    dctx.ctx = -> @
    return Promise.resolve dctx
  context: (libs, func, px) ->
    px.ldcover = window.ldcover
    if func? => func px
    return Promise.resolve px

if module? => module.exports = rsp
else if window? => window.rescope = rsp
