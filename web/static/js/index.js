var scope;
scope = new rescope({
  global: window
});
scope.init().then(function(){
  var pkg, d3pkg;
  pkg = {
    lib: [
      'assets/lib/bootstrap.native/main/bootstrap-native.min.js', 'assets/lib/bootstrap.ldui/main/bootstrap.ldui.min.js', {
        url: 'assets/lib/@loadingio/ldquery/main/ldq.min.js',
        async: false
      }, 'assets/lib/ldcover/main/index.min.js', 'assets/lib/ldview/main/index.min.js', 'js/functest.js'
    ]
  };
  d3pkg = {
    v3: 'https://d3js.org/d3.v3.min.js',
    v4: [
      {
        url: "https://d3js.org/d3.v4.js",
        async: false
      }, "https://d3js.org/d3-format.v2.min.js", "https://d3js.org/d3-array.v2.min.js", "https://d3js.org/topojson.v2.min.js", {
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
    return scope.context(pkg.lib, function(it){
      return it.functest();
    });
  }).then(function(){
    return scope.load(d3pkg.v3);
  }).then(function(){
    return scope.load(d3pkg.v4);
  }).then(function(){
    scope.context(d3pkg.v3, function(){
      var box;
      box = document.getElementById('d3v3').getBoundingClientRect();
      return d3.select('svg#d3v3').selectAll('circle').data([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100].map(function(){
        return {
          x: Math.random(),
          y: Math.random(),
          r: Math.random()
        };
      })).enter().append('circle').attr({
        cx: function(it){
          return it.x * box.width;
        },
        cy: function(it){
          return it.y * box.height;
        },
        r: function(it){
          return it.r * 20;
        },
        fill: function(){
          return '#000';
        }
      });
    });
    return debounce(1);
  }).then(function(){
    return scope.context(d3pkg.v4, function(){
      var box;
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