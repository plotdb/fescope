function functest(a, b, c){
  var ldcv;
  ldcv = new ldcover({
    root: '.ldcv'
  });
  return ldcv.toggle();
}