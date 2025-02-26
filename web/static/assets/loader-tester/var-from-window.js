console.log("OBJ is not yet defined for now: ", typeof(OBJ));
if(typeof(OBJ)==="undefined"){if(window.OBJ={a:1}) {}}
console.log("OBJ should be defined now by window.OBJ = {a: 1}", typeof(OBJ));
/* try updating OBJ directly */
OBJ.b = 2;
