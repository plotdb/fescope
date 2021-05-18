devvar = 1314
devfunc = ->
  setTimeout (->
    a = null
    a.2 = 1
    console.log "settimeout: ", devvar
  ), 1000
