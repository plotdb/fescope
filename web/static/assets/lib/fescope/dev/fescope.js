(function(){
  var fescope;
  fescope = function(){
    this.scope = {};
    return this;
  };
  fescope.prototype = import$(Object.create(Object.prototype), {
    context: function(url, func){
      var stacks, scopes, i$, to$, i, ref$, stack, scope, k, lresult$, results$ = [];
      url = Array.isArray(url)
        ? url
        : [url];
      stacks = [];
      scopes = [];
      for (i$ = 0, to$ = url.length; i$ < to$; ++i$) {
        i = i$;
        ref$ = [{}, this.scope[url[i].url || url[i]] || {}], stack = ref$[0], scope = ref$[1];
        for (k in scope) {
          stack[k] = window[k];
          window[k] = scope[k];
        }
        stacks.push(stack);
        scopes.push(scope);
      }
      func();
      for (i$ = scopes.length - 1; i$ >= 0; --i$) {
        i = i$;
        lresult$ = [];
        scope = scopes[i];
        stack = stacks[i];
        for (k in scope) {
          lresult$.push(window[k] = stack[k]);
        }
        results$.push(lresult$);
      }
      return results$;
    },
    load: function(url){
      var ret, this$ = this;
      if (!url) {
        return Promise.resolve();
      }
      url = Array.isArray(url)
        ? url
        : [url];
      ret = {};
      return new Promise(function(res, rej){
        var _;
        _ = function(list, idx){
          var items, i$, to$, i;
          items = [];
          if (idx >= list.length) {
            return res(ret);
          }
          for (i$ = idx, to$ = list.length; i$ < to$; ++i$) {
            i = i$;
            items.push(list[i]);
            if (list[i].async != null && !list[i].async) {
              break;
            }
          }
          if (!items.length) {
            return res(ret);
          }
          return Promise.all(items.map(function(it){
            return this$._load(it.url || it).then(function(it){
              return import$(ret, it);
            });
          })).then(function(){
            return this$.context(items.map(function(it){
              return it.url || it;
            }), function(){
              return _(list, idx + items.length);
            });
          });
        };
        return _(url, 0);
      });
    },
    _load: function(url){
      var this$ = this;
      return new Promise(function(res, rej){
        var script, hash, k, ref$, v;
        script = document.createElement("script");
        hash = {};
        for (k in ref$ = window) {
          v = ref$[k];
          hash[k] = v;
        }
        script.onerror = function(){
          return rej();
        };
        script.onload = function(){
          var scope, k, ref$, v;
          this$.scope[url] = scope = {};
          for (k in ref$ = window) {
            v = ref$[k];
            if (hash[k] != null || !(window[k] != null)) {
              continue;
            }
            scope[k] = window[k];
            window[k] = undefined;
          }
          return res(scope);
        };
        script.setAttribute('src', url);
        return document.body.appendChild(script);
      });
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = fescope;
  }
  if (typeof window != 'undefined' && window !== null) {
    window.fescope = fescope;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
