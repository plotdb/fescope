(function(){
  var rescope;
  rescope = function(opt){
    opt == null && (opt = {});
    this.opt = import$({
      inFrame: false
    }, opt);
    this.inFrame = this.opt.inFrame;
    this.global = opt.global || (typeof global != 'undefined' && global !== null ? global : window);
    this.scope = {};
    return this;
  };
  rescope.func = [];
  rescope.prototype = import$(Object.create(Object.prototype), {
    peekScope: function(){
      console.log("in delegate iframe: " + !!this.global._rescopeDelegate);
      return this.global._rescopeDelegate;
    },
    init: function(){
      var this$ = this;
      if (this.inFrame) {
        return Promise.resolve();
      }
      return new Promise(function(res, rej){
        var node, ref$, code;
        node = document.createElement('iframe');
        node.setAttribute('name', "delegator-" + Math.random().toString(36).substring(2));
        node.setAttribute('sandbox', 'allow-same-origin allow-scripts');
        ref$ = node.style;
        ref$.opacity = 0;
        ref$.zIndex = -1;
        ref$.pointerEvents = 'none';
        ref$.width = '0px';
        ref$.height = '0px';
        code = "<html><body><script>\nfunction init() {\n  if(!window._scope) { window._scope = new rescope({inFrame:true,global:window}) }\n}\nfunction load(url) { return _scope.load(url); }\nfunction context(url,func) { _scope.context(url,func,true); }\n</script></body></html>";
        node.onerror = function(it){
          return rej(it);
        };
        node.onload = function(){
          var ref$;
          ref$ = this$.iframe = node.contentWindow;
          ref$.rescope = rescope;
          ref$._rescopeDelegate = true;
          this$.iframe.init();
          this$.frameScope = this$.iframe._scope.scope;
          return res();
        };
        node.src = URL.createObjectURL(new Blob([code], {
          type: 'text/html'
        }));
        return document.body.appendChild(node);
      });
    },
    context: function(url, func, untilResolved){
      var stacks, scopes, context, i$, to$, i, ref$, stack, scope, k, ret, p, this$ = this;
      untilResolved == null && (untilResolved = false);
      url = Array.isArray(url)
        ? url
        : [url];
      stacks = [];
      scopes = [];
      context = {};
      for (i$ = 0, to$ = url.length; i$ < to$; ++i$) {
        i = i$;
        ref$ = [{}, this.scope[url[i].url || url[i]] || {}], stack = ref$[0], scope = ref$[1];
        for (k in scope) {
          stack[k] = this.global[k];
          this.global[k] = scope[k];
          context[k] = scope[k];
        }
        stacks.push(stack);
        scopes.push(scope);
      }
      ret = func(context);
      p = untilResolved && ret && ret.then
        ? ret
        : Promise.resolve();
      return p.then(function(){
        var i$, i, lresult$, scope, stack, k, results$ = [];
        for (i$ = scopes.length - 1; i$ >= 0; --i$) {
          i = i$;
          lresult$ = [];
          scope = scopes[i];
          stack = stacks[i];
          for (k in scope) {
            lresult$.push(this$.global[k] = stack[k]);
          }
          results$.push(lresult$);
        }
        return results$;
      });
    },
    load: function(url){
      var this$ = this;
      if (!url) {
        return Promise.resolve();
      }
      url = Array.isArray(url)
        ? url
        : [url];
      return Promise.resolve().then(function(){
        if (!this$.inFrame) {
          return this$.iframe.load(url);
        }
      }).then(function(){
        return new Promise(function(res, rej){
          var _;
          _ = function(list, idx, ctx){
            var items, i$, to$, i;
            idx == null && (idx = 0);
            ctx == null && (ctx = {});
            if (idx >= list.length) {
              return res(ctx);
            }
            items = [];
            for (i$ = idx, to$ = list.length; i$ < to$; ++i$) {
              i = i$;
              items.push(list[i]);
              if (list[i].async != null && !list[i].async) {
                break;
              }
            }
            if (!items.length) {
              return res(ctx);
            }
            return Promise.all(items.map(function(it){
              var url;
              url = it.url || it;
              return this$._load(url, ctx, (this$.frameScope || (this$.frameScope = {}))[url]);
            })).then(function(){
              return this$.context(items.map(function(it){
                return it.url || it;
              }), function(c){
                return _(list, idx + items.length, import$(ctx, c));
              }, true);
            })['catch'](function(it){
              return rej(it);
            });
          };
          return _(url, 0);
        });
      });
    },
    _wrapperAlt: function(url, code, context, prescope){
      var this$ = this;
      context == null && (context = {});
      prescope == null && (prescope = {});
      return new Promise(function(res, rej){
        var _code, k, v, _postcode, _forceScope, id, script, hash, ref$;
        _code = "";
        _code = (function(){
          var ref$, results$ = [];
          for (k in ref$ = context) {
            v = ref$[k];
            results$.push("var " + k + " = context." + k + ";");
          }
          return results$;
        }()).join('\n') + '\n';
        _postcode = (function(){
          var ref$, results$ = [];
          for (k in ref$ = prescope) {
            v = ref$[k];
            results$.push("if(typeof(" + k + ") != 'undefined') { this." + k + " = " + k + "; }");
          }
          return results$;
        }()).join('\n') + '\n';
        _forceScope = "var global = this;\nvar globalThis = this;\nvar window = this;\nvar self = this;";
        _forceScope = "";
        id = "x" + Math.random().toString(36).substring(2);
        _code = "/* URL: " + url + " */\nrescope.func." + id + " = function(context) {\n  return (function() {\n    " + _code + "\n    " + _forceScope + "\n    " + code + "\n    " + _postcode + "\n    return this;\n  }).apply(context);\n}";
        script = this$.global.document.createElement("script");
        hash = {};
        for (k in ref$ = this$.global) {
          v = ref$[k];
          hash[k] = v;
        }
        script.onerror = function(it){
          return rej(it);
        };
        script.onload = function(){
          (this$.func || (this$.func = {}))[url] = rescope.func[id];
          return res(import$({}, (this$.func || (this$.func = {}))[url](context)));
        };
        script.setAttribute('src', URL.createObjectURL(new Blob([_code], {
          type: 'text/javascript'
        })));
        return this$.global.document.body.appendChild(script);
      });
    },
    _wrapper: function(url, code, context, prescope){
      var _code, k, v, _postcode, _forceScope, ret;
      context == null && (context = {});
      prescope == null && (prescope = {});
      _code = "";
      _code = (function(){
        var ref$, results$ = [];
        for (k in ref$ = context) {
          v = ref$[k];
          results$.push("var " + k + " = context." + k + ";");
        }
        return results$;
      }()).join('\n') + '\n';
      _postcode = (function(){
        var ref$, results$ = [];
        for (k in ref$ = prescope) {
          v = ref$[k];
          results$.push("if(typeof(" + k + ") != 'undefined') { this." + k + " = " + k + "; }");
        }
        return results$;
      }()).join('\n') + '\n';
      _forceScope = "var global = this;\nvar globalThis = this;\nvar window = this;\nvar self = this;";
      _forceScope = "";
      _code = "(function() {\n  " + _code + "\n  " + _forceScope + "\n  " + code + "\n  " + _postcode + "\n  return this;\n}).apply(context);";
      ret = eval(_code);
      return import$({}, ret);
    },
    _load: function(url, ctx, prescope){
      var this$ = this;
      ctx == null && (ctx = {});
      prescope == null && (prescope = {});
      if (this.inFrame) {
        return this._loadInFrame(url);
      }
      return ld$.fetch(url, {
        method: "GET"
      }, {
        type: 'text'
      }).then(function(code){
        return this$._wrapperAlt(url, code, ctx, prescope);
      }).then(function(c){
        return this$.scope[url] = c;
      });
    },
    _loadInFrame: function(url){
      var this$ = this;
      return new Promise(function(res, rej){
        var script, hash, k, ref$, v, fullUrl;
        script = this$.global.document.createElement("script");
        hash = {};
        for (k in ref$ = this$.global) {
          v = ref$[k];
          hash[k] = v;
        }
        script.onerror = function(it){
          return rej(it);
        };
        script.onload = function(){
          var scope, k, v, ref$;
          if (this$.scope[url]) {
            scope = this$.scope[url];
            for (k in scope) {
              v = scope[k];
              scope[k] = this$.global[k];
              this$.global[k] = hash[k];
            }
          } else {
            this$.scope[url] = scope = {};
            for (k in ref$ = this$.global) {
              v = ref$[k];
              if (hash[k] != null || !(this$.global[k] != null)) {
                continue;
              }
              scope[k] = this$.global[k];
              this$.global[k] = hash[k];
            }
          }
          return res(scope);
        };
        fullUrl = /(https?:)?\/\//.exec(url)
          ? url
          : window.location.origin + (url[0] === '/' ? '' : '/') + url;
        script.setAttribute('src', fullUrl);
        return this$.global.document.body.appendChild(script);
      });
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = rescope;
  }
  if (typeof window != 'undefined' && window !== null) {
    window.rescope = rescope;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
