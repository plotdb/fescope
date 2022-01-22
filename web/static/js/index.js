var scope;
scope = new rescope({
  global: window,
  registry: function(arg$){
    var name, version, path, url;
    name = arg$.name, version = arg$.version, path = arg$.path;
    url = "https://unpkg.com/" + name + (version && "@" + version || '') + (path && "/" + path || '');
    return fetch(url).then(function(response){
      var ret, v;
      ret = /^https:\/\/unpkg.com\/([^@]+)@([^/]+)\//.exec(response.url) || [];
      v = ret[2];
      return response.text().then(function(it){
        return {
          version: v || version,
          content: it
        };
      });
    });
  }
});
if ((typeof useFakescope != 'undefined' && useFakescope !== null) && useFakescope) {
  console.log(" - use fakescope: true ");
  scope = {
    init: function(){
      return Promise.resolve();
    },
    peekScope: function(){
      return Promise.resolve();
    },
    load: function(){
      return Promise.resolve();
    },
    context: function(lib, cb){
      return Promise.resolve(cb(window));
    }
  };
}
scope.init().then(function(){
  var pkg, d3pkg;
  pkg = {
    lib: [
      'assets/lib/bootstrap.native/main/dist/bootstrap-native.min.js', {
        url: 'assets/lib/@loadingio/ldquery/main/index.min.js',
        async: false
      }, 'assets/lib/ldcover/main/index.min.js', 'assets/lib/ldview/main/index.min.js', 'js/functest.js'
    ]
  };
  d3pkg = {
    v3: {
      name: 'd3',
      version: "3",
      path: "d3.min.js"
    },
    v4: [
      {
        url: "/assets/dev/d3.v4.js",
        async: false
      }, "https://d3js.org/d3-format.v2.min.js", {
        name: "d3-array",
        version: "2",
        path: "dist/d3-array.min.js"
      }, "https://d3js.org/topojson.v2.min.js", {
        url: "https://d3js.org/d3-color.v1.min.js",
        async: false
      }, {
        url: "https://d3js.org/d3-interpolate.v1.min.js",
        async: false
      }, "https://d3js.org/d3-scale-chromatic.v1.min.js", "https://d3js.org/d3-dispatch.v2.min.js", "https://d3js.org/d3-quadtree.v2.min.js", "https://d3js.org/d3-timer.v2.min.js", "https://d3js.org/d3-force.v2.min.js"
    ]
  };
  scope.peekScope();
  return scope.load(pkg.lib).then(function(){
    return scope.context(pkg.lib, function(arg$){
      var functest;
      functest = arg$.functest;
      return functest();
    });
  }).then(function(){
    return scope.load(d3pkg.v3);
  }).then(function(){
    return scope.load(d3pkg.v4);
  }).then(function(){
    scope.context(d3pkg.v3, function(arg$){
      var d3, box;
      d3 = arg$.d3;
      console.log("[d3 v3]", d3.version);
      box = document.getElementById('d3v3').getBoundingClientRect();
      return d3.select('svg#d3v3').selectAll('circle').data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100].map(function(){
        return {
          x: Math.random(),
          y: Math.random(),
          r: Math.random()
        };
      })).enter().append('circle').attr('cx', function(it){
        return it.x * box.width;
      }).attr('cy', function(it){
        return it.y * box.height;
      }).attr('r', function(it){
        return it.r * 20;
      }).attr('fill', function(){
        return '#000';
      });
    });
    return debounce(1);
  }).then(function(){
    return scope.context(d3pkg.v4, function(arg$){
      var d3, box;
      d3 = arg$.d3;
      console.log("[d3 v4]", d3.version);
      box = document.getElementById('d3v4').getBoundingClientRect();
      return d3.select('svg#d3v4').selectAll('circle').data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100].map(function(){
        return {
          x: Math.random(),
          y: Math.random(),
          r: Math.random()
        };
      })).enter().append('circle').attr('cx', function(it){
        return it.x * box.width;
      }).attr('cy', function(it){
        return it.y * box.height;
      }).attr('r', function(it){
        return it.r * 20;
      }).attr('fill', function(){
        return '#000';
      });
    });
  });
});