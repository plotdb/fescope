rsp.prototype.bundle = (libs = {}) ->
  # while `@load` does this, we still need this line to convert libs to cached object in `bundle`
  libs = (if Array.isArray(libs) => libs else [libs]).map (o) ~> @cache o
  # dedup
  hash = {}
  libs
    .filter -> it and it.id
    .map -> hash[it.id] = it
  libs = [v for k,v of hash]
  @load(libs, null, true, true).then ~>
    codes = libs
      .filter -> it.code
      .map (o) ~>
        # we need ctx for `@_wrap` otherwise lib won't be able to access dependencies.
        # before we can solve this problem, we cache code only first.
        /*
        code = @_wrap o, {}, code-only: true
        """{#{if o.url => "url: '#{o.url}'," else ''}id: '#{o.id}',gen: #code}"""
        */
        JSON.stringify(o{url, id, name, version, path, code})
    Promise.resolve "[#{codes.join(',')}].forEach(function(o){rescope.cache(o);})"
