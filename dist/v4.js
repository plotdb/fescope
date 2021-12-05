/*
lib spec
  id: from `rescope.id`
  url, name, version, path
  prop
  code: source code for this library.

declarative version ( used in dependency declaration )
  url, name, version, path, ..?
*/
(function(){
  var win, doc, _fetch, proxin, ref$, rsp;
  _fetch = function(url, cfg){
    return fetch(url, cfg).then(function(ret){
      var ref$;
      if (ret && ret.ok) {
        return ret.text();
      }
      if (!ret) {
        return Promise.reject((ref$ = new Error("404"), ref$.name = 'lderror', ref$.id = 404, ref$));
      }
      return ret.clone().text().then(function(t){
        var i, e, ref$, j, er;
        i = ret.status || 404;
        e = (ref$ = new Error(i + " " + t), ref$.name = 'lderror', ref$.id = i, ref$.message = t, ref$);
        try {
          if ((j = JSON.parse(t)) && j.name === 'lderror') {
            import$(e, j).json = j;
          }
        } catch (e$) {
          er = e$;
        }
        return Promise.reject(e);
      });
    });
  };
  proxin = function(o){
    var ifr, ref$, attr, func, this$ = this;
    o == null && (o = {});
    this.lc = o.context || {};
    this.id = Math.random().toString(36).substring(2);
    if (o.iframe) {
      this.iframe = o.iframe;
    } else {
      this.iframe = ifr = doc.createElement('iframe');
      ref$ = ifr.style;
      ref$.position = 'absolute';
      ref$.top = 0;
      ref$.left = 0;
      ref$.width = 0;
      ref$.height = 0;
      ref$.pointerEvents = 'none';
      ref$.opacity = 0;
      ifr.setAttribute('title', "rescope script loader");
      ifr.setAttribute('name', "pdb-proxin-" + this.id);
      ifr.setAttribute('sandbox', 'allow-same-origin allow-scripts');
      doc.body.appendChild(ifr);
    }
    attr = Object.fromEntries(Reflect.ownKeys(this.iframe.contentWindow).map(function(it){
      return [it, true];
    }));
    func = {};
    this._proxy = new Proxy(o.target || win, {
      get: function(t, k, o){
        if (this$.lc[k] != null) {
          return this$.lc[k];
        }
        if (func[k] != null) {
          return func[k];
        }
        if (attr[k] == null) {
          return undefined;
        }
        if (typeof t[k] === 'function') {
          return func[k] = t[k].bind(t);
        }
        return t[k];
      },
      set: function(t, k, v){
        if (attr[k]) {
          t[k] = v;
          return true;
        }
        this$.lc[k] = v;
        return true;
      }
    });
    return this;
  };
  proxin.prototype = (ref$ = Object.create(Object.prototype), ref$.proxy = function(){
    return this._proxy;
  }, ref$.ctx = function(){
    return this.lc;
  }, ref$);
  rsp = function(o){
    var ifr, ref$;
    o == null && (o = {});
    this.id = Math.random().toString(36).substring(2);
    this.iframe = ifr = doc.createElement('iframe');
    this._cache = {};
    this.proxy = new proxin();
    this.registry(o.registry || "/assets/lib/");
    ref$ = ifr.style;
    ref$.position = 'absolute';
    ref$.top = 0;
    ref$.left = 0;
    ref$.width = 0;
    ref$.height = 0;
    ref$.pointerEvents = 'none';
    ref$.opacity = 0;
    ifr.setAttribute('title', "rescope script loader");
    ifr.setAttribute('name', "pdb-rescope-" + this.id);
    ifr.setAttribute('sandbox', 'allow-same-origin allow-scripts');
    doc.body.appendChild(ifr);
    ifr.contentWindow.document.body.innerHTML = (o.preloads || []).map(function(it){
      return "<script type=\"text/javascript\" src=\"" + it + "\"></script>";
    }).join('');
    return this;
  };
  rsp.env = function(it){
    var ref$;
    return ref$ = [it, it.document], win = ref$[0], doc = ref$[1], ref$;
  };
  rsp.prop = {
    legacy: {
      webkitStorageInfo: true
    }
  };
  rsp.id = function(o){
    return o.id || o.url || o.name + "@" + o.version + "/" + o.path;
  };
  rsp._cache = {};
  rsp.cache = function(o){
    var r;
    if (typeof o === 'string') {
      o = {
        url: o
      };
    }
    if (!o.id) {
      o.id = rsp.id(o);
    }
    if (r = rsp._cache[o.id]) {
      return r;
    }
    return rsp._cache[o.id] = import$({}, o);
  };
  rsp.bundle = function(o){
    o == null && (o = {});
    o = import$({}, o);
    if (!o.id) {
      return o.id = rsp.id(o);
    }
  };
  rsp.prototype = (ref$ = Object.create(Object.prototype), ref$.peekScope = function(){
    return false;
  }, ref$.init = function(){
    return Promise.resolve();
  }, ref$._url = function(o){
    var that;
    return typeof o === 'string'
      ? o
      : (that = o.url)
        ? that
        : this._reg(o);
  }, ref$.registry = function(v){
    if (typeof v === 'string') {
      if (v[v.length - 1] === '/') {
        v = v.substring(0, v.length - 1);
      }
      return this._reg = function(v){
        return function(o){
          return v + "/" + o.name + "/" + (o.version || 'main') + "/" + (o.path || 'index.min.js');
        };
      }(v);
    } else {
      return this._reg = v;
    }
  }, ref$.cache = function(o){
    var r, that;
    if (typeof o === 'string') {
      o = {
        url: o
      };
    }
    if (!o.id) {
      o.id = rsp.id(o);
    }
    if (r = this._cache[o.id]) {
      return r;
    }
    if (that = rsp._cache[o.id]) {
      return this._cache[o.id] = that;
    }
    return this._cache[o.id] = import$({}, o);
  }, ref$.exports = function(o){
    var ctx, libs, ref$, hash, iw, k, results$ = [];
    o == null && (o = {});
    ctx = o.ctx || {};
    libs = typeof o.libs === 'string'
      ? [o.libs]
      : o.libs || [];
    ref$ = [{}, this.iframe.contentWindow], hash = ref$[0], iw = ref$[1];
    for (k in ctx) {
      hash[k] = iw[k];
      iw[k] = ctx[k];
    }
    this._exports(libs, 0);
    for (k in ctx) {
      results$.push(iw[k] = hash[k]);
    }
    return results$;
  }, ref$._exports = function(libs, idx){
    var lib, ref$, hash, fprop, iw, att1, k, att2, results$ = [];
    idx == null && (idx = 0);
    if (!(lib = libs[idx])) {
      return;
    }
    lib = this.cache(lib);
    ref$ = [{}, lib.fprop, this.iframe.contentWindow], hash = ref$[0], fprop = ref$[1], iw = ref$[2];
    if (!fprop) {
      lib.fprop = fprop = {};
      lib.prop = {};
      att1 = Object.fromEntries(Reflect.ownKeys(iw).filter(function(it){
        return !rsp.prop.legacy[it];
      }).map(function(it){
        return [it, true];
      }));
      for (k in att1) {
        hash[k] = iw[k];
      }
      iw.eval(lib.code);
      att2 = Object.fromEntries(Reflect.ownKeys(iw).filter(function(it){
        return !rsp.prop.legacy[it];
      }).map(function(it){
        return [it, true];
      }));
      for (k in att2) {
        if (iw[k] === hash[k] || k === 'NaN') {
          continue;
        }
        fprop[k] = iw[k];
        lib.prop[k] = null;
        lib.propIniting = true;
      }
    } else {
      for (k in fprop) {
        hash[k] = iw[k];
        iw[k] = fprop[k];
      }
    }
    this._exports(libs, idx + 1);
    for (k in fprop) {
      results$.push(iw[k] = hash[k]);
    }
    return results$;
  }, ref$._wrap = function(o, ctx){
    var ctxId, k, prop, code;
    o == null && (o = {});
    ctx == null && (ctx = {});
    ctxId = (function(){
      var results$ = [];
      for (k in ctx) {
        results$.push(k);
      }
      return results$;
    }()).join(',');
    prop = o.prop || {};
    code = "var window, global, globalThis, self, __ret = {}; __win = {};\nwindow = global = globalThis = window = scope;";
    for (k in prop) {
      code += "var " + k + "; __win['" + k + "'] = win['" + k + "']; win['" + k + "'] = undefined;";
    }
    for (k in ctx) {
      code += "var " + k + " = window['" + k + "'] = ctx['" + k + "'];";
    }
    code += o.code + ";";
    for (k in prop) {
      code += "__ret['" + k + "'] = " + k + " || window['" + k + "'] || win['" + k + "'] || this['" + k + "'];\nwin['" + k + "'] = __win['" + k + "'];";
    }
    code += "return __ret;";
    return new Function("scope", "ctx", "win", code);
  }, ref$.load = function(libs, px){
    var ctx, proxy, ps, this$ = this;
    libs = (Array.isArray(libs)
      ? libs
      : [libs]).map(function(lib){
      return this$.cache(lib);
    });
    px = libs.px
      ? libs.px
      : libs.px = px || new proxin();
    ctx = px.ctx();
    proxy = px.proxy();
    ps = libs.map(function(lib){
      if (lib.code) {
        return Promise.resolve();
      }
      return ld$.fetch(this$._url(lib), {
        method: 'GET'
      }, {
        type: 'text'
      }).then(function(code){
        return lib.code = code;
      });
    });
    return Promise.all(ps).then(function(){
      this$.exports({
        libs: libs
      });
      return libs.map(function(lib){
        if (lib.propIniting) {
          lib.gen = this$._wrap(lib, ctx);
          lib.prop = lib.gen(proxy, ctx, window);
          lib.propIniting = false;
        }
        return import$(ctx, lib.prop);
      });
    }).then(function(){
      return ctx;
    });
  }, ref$.context = function(libs, func, proxy){
    var ref$;
    if (typeof func !== 'function') {
      ref$ = [proxy, func], func = ref$[0], proxy = ref$[1];
    }
    return this.load(libs, proxy).then(function(ctx){
      return func(ctx);
    });
  }, ref$);
  rsp.env(typeof self != 'undefined' && self !== null ? self : globalThis);
  rsp.proxin = proxin;
  if (typeof module != 'undefined' && module !== null) {
    module.exports = rsp;
  } else if (window) {
    window.rescope = rsp;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
