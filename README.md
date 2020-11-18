# rescope

experimental project. Load and scope any external JavaScript and reload scope on demand. 

For example, assume here are the list of js url we'd like to load, which kept in `libs` variable:

 - assets/lib/bootstrap.native/main/bootstrap-native.min.js
 - assets/lib/bootstrap.ldui/main/bootstrap.ldui.min.js
 - assets/lib/@loadingio/ldquery/main/ldq.min.js
 - assets/lib/ldcover/main/ldcv.min.js
 - assets/lib/ldview/main/ldview.min.js


We can load all above js files with rescope, with a resolveed hash containing all imported variables:

    scope = new rescope!
    scope.load libs .then (hash) -> myfunc!


However, we actually don't have to access the returned `hash` object. Instead we simply enter desired context:

    myfunc = ->
      scope.context libs, ->
        # now ldCover and ld$ are available ...
        ldcv = new ldCover do
          root: ld$.find('.ldcv', 0)
      # ... but unavailable outside context.
      assert (ldCover? or ld$?), false

This is useful when you need the same library with different versions:

    d3 = do
      v3: 'https://d3js.org/d3.v3.min.js'
      b6: 'https://d3js.org/d3.v6.min.js'

    scope = new rescope!
    scope.load d3.v6
      .then -> scope.load d3.v3
      .then -> scope.context d3.v6, -> /* run v6 code ... */
      .then -> scope.context d3.v3, -> /* run v3 code ... */


## Asynchronous Script Loading

By default all script are loaded asynchronously. You can force them loaded in synchronous manner, by extending URL into object with following options:

 - url: URL to load
 - async: load asynchronously if set to true. default true.


## Delegate Window

You can load libraries with an iframe window object as delegate:

    new rescope({delegate: true});

With delegate set to true, all libraries loaded with the rescope object will work under a separated window and document object. Please note, it won't work as expected when cross refer libraries between two different global scope, so don't mix up libraries in different global scope.


## TODO

 - Browser compatibility check
   - works in all major browsers ( latest Chrome, Firefox, Safari, Opera, Edge )
   - doesn't work in IE11
 - Performance benchmark
 - returned scope might be affected if host window is running some scripts that update window object in the same time when some scripts are loading. This can be resolved by loading scripts twice - one in delegate to determine the keys to capture, and one in host to capture based on those keys.




## License 

MIT
