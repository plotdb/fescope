 (function() { function pug_attr(t,e,n,r){if(!1===e||null==e||!e&&("class"===t||"style"===t))return"";if(!0===e)return" "+(r?t:t+'="'+t+'"');var f=typeof e;return"object"!==f&&"function"!==f||"function"!=typeof e.toJSON||(e=e.toJSON()),"string"==typeof e||(e=JSON.stringify(e),n||-1===e.indexOf('"'))?(n&&(e=pug_escape(e))," "+t+'="'+e+'"'):" "+t+"='"+e.replace(/'/g,"&#39;")+"'"}
function pug_escape(e){var a=""+e,t=pug_match_html.exec(a);if(!t)return e;var r,c,n,s="";for(r=t.index,c=0;r<a.length;r++){switch(a.charCodeAt(r)){case 34:n="&quot;";break;case 38:n="&amp;";break;case 60:n="&lt;";break;case 62:n="&gt;";break;default:continue}c!==r&&(s+=a.substring(c,r)),c=r+1,s+=n}return c!==r?s+a.substring(c,r):s}
var pug_match_html=/["&<>]/;
function pug_rethrow(e,n,r,t){if(!(e instanceof Error))throw e;if(!("undefined"==typeof window&&n||t))throw e.message+=" on line "+r,e;var o,a,i,s;try{t=t||require("fs").readFileSync(n,{encoding:"utf8"}),o=3,a=t.split("\n"),i=Math.max(r-o,0),s=Math.min(a.length,r+o)}catch(t){return e.message+=" - could not read from "+n+" ("+t.message+")",void pug_rethrow(e,null,r)}o=a.slice(i,s).map(function(e,n){var t=n+i+1;return(t==r?"  > ":"    ")+t+"| "+e}).join("\n"),e.path=n;try{e.message=(n||"Pug")+":"+r+"\n"+o+"\n\n"+e.message}catch(e){}throw e}function template(locals) {var pug_html = "", pug_mixins = {}, pug_interp;var pug_debug_filename, pug_debug_line;try {;
    var locals_for_with = (locals || {});
    
    (function (libLoader, version) {
      ;pug_debug_line = 1;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003C!DOCTYPE html\u003E";
;pug_debug_line = 2;pug_debug_filename = "\u002FUsers\u002Ftkirby\u002Fworkspace\u002Fzbryikt\u002Fplotdb\u002Fprojects\u002Frescope\u002Fnode_modules\u002F@plotdb\u002Fsrcbuild\u002Fdist\u002Flib.pug";
if(!libLoader) {
  libLoader = {
    js: {url: {}},
    css: {url: {}},
    root: function(r) { this._root = r; },
    _r: "/assets/lib",
    _v: "",
    version: function(v) { libLoader._v = (v ? "?v=" + v : ""); }
  }
  if(version) { libLoader.version(version); }
}

;pug_debug_line = 15;pug_debug_filename = "\u002FUsers\u002Ftkirby\u002Fworkspace\u002Fzbryikt\u002Fplotdb\u002Fprojects\u002Frescope\u002Fnode_modules\u002F@plotdb\u002Fsrcbuild\u002Fdist\u002Flib.pug";












































;pug_debug_line = 30;pug_debug_filename = "\u002FUsers\u002Ftkirby\u002Fworkspace\u002Fzbryikt\u002Fplotdb\u002Fprojects\u002Frescope\u002Fnode_modules\u002F@plotdb\u002Fsrcbuild\u002Fdist\u002Flib.pug";






























;pug_debug_line = 2;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003Chtml\u003E";
;pug_debug_line = 3;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003Chead\u003E\u003C\u002Fhead\u003E";
;pug_debug_line = 4;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003Cbody\u003E";
;pug_debug_line = 5;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003Cscript\u003E";
;pug_debug_line = 5;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "var proxin,ref$;proxin=function(){var e=this;this.hash={};this.proxy=new Proxy(window,{set:function(o,n,r){console.log(\"proxy.set: \",n);if(!e.hash[n]){e.hash[n]=o[n]}o[n]=r;return true}});return this};proxin.func={};proxin.prototype=(ref$=Object.create(Object.prototype),ref$.enter=function(){return wind},ref$.wrap=function(o){var n,r=this;this.id=Math.random().toString(16).substring(2);o='proxin.func[\"'+this.id+'\"] = pp = function(proxy) {\\nconsole.log(1);\\n\u002F*\\nvar global = proxy; \\nvar globalThis = proxy; \\nvar self = proxy; \\nvar window = proxy; \\n*\u002F\\nconsole.log(2);\\n'+o+\"\\nconsole.log(3);\\n};\\npp(document.currentScript.proxy);\";n=document.createElement(\"script\");n.proxy=this.proxy;n.onerror=function(){};console.log(\"a\");n.onload=function(){console.log(\"onload\");return proxin.func[r.id](r.proxy)};n.appendChild(document.createTextNode(o));console.log(\"b\");return document.body.appendChild(n)},ref$.restore=function(){var o,n,r,e=[];for(o in n=this.hash){r=n[o];e.push(window[o]=r)}return e},ref$);window.proxin=proxin;\u003C\u002Fscript\u003E";
;pug_debug_line = 6;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "\u003Cscript\u003E";
;pug_debug_line = 6;pug_debug_filename = "src\u002Fpug\u002Fdev\u002Ffakewin\u002Findex.pug";
pug_html = pug_html + "var p,code;p=new proxin;code='console.log(\"code executed\");\\nfunction mycls() {\\n  this.name = \"mycls\";\\n  return this;\\n}';p.wrap(code);\u003C\u002Fscript\u003E\u003C\u002Fbody\u003E\u003C\u002Fhtml\u003E";
    }.call(this, "libLoader" in locals_for_with ?
        locals_for_with.libLoader :
        typeof libLoader !== 'undefined' ? libLoader : undefined, "version" in locals_for_with ?
        locals_for_with.version :
        typeof version !== 'undefined' ? version : undefined));
    ;} catch (err) {pug_rethrow(err, pug_debug_filename, pug_debug_line);};return pug_html;}; module.exports = template; })() 