var devvar, devfunc;
devvar = 1314;
devfunc = function(){
  return setTimeout(function(){
    var a;
    a = null;
    a[2] = 1;
    return console.log("settimeout: ", devvar);
  }, 1000);
};