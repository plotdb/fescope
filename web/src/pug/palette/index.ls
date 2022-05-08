scope = new rescope!
scope.registry ({name, version, path, type}) -> "/assets/lib/#name/#version/#path"
_ctx = rescope.dual-context!
scope.load [{name: "ldpalettepicker", version: "main", path: "index.min.js", async: false}], _ctx
  .then ({ldpp}) ->
    console.log _ctx
    scope.load [{name: "ldpalettepicker", version: "main", path: "all.palettes.js"}], _ctx
      .then ->
        console.log ldpp.get \all
