# rescope

experimental project. Load and scope any external JavaScript and reload scope on demand. 

For example, assume here are the list of js url we'd like to load, which kept in `libs` variable:

 - assets/lib/bootstrap.native/main/bootstrap-native.min.js
 - assets/lib/bootstrap.ldui/main/bootstrap.ldui.min.js
 - assets/lib/@loadingio/ldquery/main/ldq.min.js
 - assets/lib/ldcover/main/ldcv.min.js
 - assets/lib/ldview/main/ldview.min.js


We can load all above js files with rescope, with a resolveed context containing all imported variables:

    scope = new rescope!
    scope.load libs .then (context) -> myfunc!


However, we actually don't have to access the returned `context` object. Instead we simply enter desired context:

    myfunc = ->
      scope.context libs, (context) ->
        # now ldCover and ld$ are available ...
        ldcv = new ldCover do
          root: ld$.find('.ldcv', 0)
      # ... but unavailable outside context.
      assert (ldCover? or ld$?), false

This is useful when you need the same library with different versions:

    d3 = do
      v3: 'https://d3js.org/d3.v3.min.js'
      v6: 'https://d3js.org/d3.v6.min.js'

    scope = new rescope!
    scope.load d3.v6
      .then -> scope.load d3.v3
      .then -> scope.context d3.v6, -> /* run v6 code ... */
      .then -> scope.context d3.v3, -> /* run v3 code ... */

Note that for asynchronous functions, context may change if there are concurrent `scope.context` running so window object may be overwritten In this case, always rely on the passed `context` object to access required libraries.


## Asynchronous Script Loading

By default all script are loaded asynchronously. You can force them loaded in synchronous manner, by extending URL into object with following options:

 - url: URL to load
 - async: load asynchronously if set to true. default true.


## Delegate Window

By default `rescope` uses iframe window to preload libraries and peek variables they defined. The iframe is called delegate window. Apparently behavior for the host and the delegate is not the same.

We specify an option `delegate` and set it to false to tell `Rescope` that this instance doesn't use delegate ( itself is a delegate ):

    new rescope({delegate: false});

Additionally, you can also run code within delegate's context, by setting 'useDelegateLib' to `true`:

    new resope({useDelegateLib: true})

This will only work when `delegate` is set to true ( which is by default ). With `useDelegateLib` set to true, all libraries loaded with the rescope object will work under a separated window and document object. Please note, it won't work as expected when cross refer libraries between two different global scope, so don't mix up libraries in different global scope.

Even with `useDelegateLib` set to true, you can still enter host context by setting the second parameter to `false` when calling `context`:

    res = new rescope({useDelegateLib: true});
    res.context("some-lib", false, function() { ... });


## TODO

 - Browser compatibility check
   - works in all major browsers ( latest Chrome, Firefox, Safari, Opera, Edge )
   - doesn't work in IE11
 - Performance benchmark


## Note

 - This is not meant to be used for sandboxing or for security reason. Rescope never prevent any scripts from accessing document, and all scripts are still run in the main thread.
 - some libraries such as `d3` may check and use object with the name they are going to use if exists. Thus we always have to restore context in case of disrupt their initialization process.


## Resources

 - Realm may help in what we want to do:
   - https://github.com/tc39/proposal-realms/#ecmascript-spec-proposal-for-realms-api
   - https://github.com/Agoric/realms-shim
   - https://www.figma.com/blog/how-we-built-the-figma-plugin-system/
 - also check how Vue does its own scoping in template:
   - https://github.com/vuejs/vue/blob/v2.6.10/src/core/instance/proxy.js#L9


## License 

MIT
