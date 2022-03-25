# Change Logs

## v4.1.3

 - add missing `@plotdb/semver`


## v4.1.2

 - fix bug: for `window` function may not be in attributes, but we check for `attr` before looking in `func`, which leads to function not found.


## v4.1.1

 - downgrade `node-fetch` back to `v2.6.7` to make it work in nodejs


## v4.1.0

 - fix bug: registry.fetch is used even if not defined.
 - default empty in version / path when building id
 - lookup acceptable versions in cache if version range provided.
 - support custom registry that return content + version directly.
 - use minimized dist file as main / browser default file
 - upgrade modules
 - patch test code to make it work with upgraded modules
 - release with compact directory structure


## v4.0.5

 - dedup in bundler
 - fix typo in id generation


## v4.0.4

 - temporarily remove `gen` from bundled code since there are bugs yet to be fixed.


## v4.0.3

 - adding a parameter for skipping ctx since bundler doesn't need to calculate exports and update ctx.


## v4.0.2 

 - fix bug: iframe context doesn't work since we never keep it result, causing multi-phase loading failed.


## v4.0.1

 - fix bug: `prop-initing` should be true once we are going to init the lib


## v4.0.0

 - rename `rescope.js` to `index.js` - remove `rescope.js` and `rescope.min.js`
 - `context` no longer pollute `window` object - a proxy for `window` is used instead.
 - support bundling, rebundling and bundle loading
 - remove ldquery dependency
 - support nodejs context


## v3.0.2

 - prevent from accessing deprecated attributes.
 - upgrade @zbryikt/template and fix test code building
 - add `index.js` and `index.min.js` to deprecated `rescope.js` and `rescope.min.js`
 - fix bug: missing var decalration in `load-in-frame`
 - use `index.js` as `main` file in package.json
 - support fetch in nodejs context
 - prepare module by checking window against existence instead of value

## v3.0.1

 - minimize js further
 - upgrade modules for test code
 - add `title` in iframe for accessibility


## v3.0.0

 - rename `set-registry` to `registry`.
 - update in-frame scope when calling `registry`.
 - align registry logic with `@plotdb/csscope` and `@plotdb/block`.
 - change from `lib` to `assets/lib` for default registry root


## v2.1.2

 - add meta charset information in iframe HTML code to prevent some browser warning;
 - add `prejs` option for injecting pre-requirement such as polyfills


## v2.1.1

 - re-enable polluting global scope with context call, but only for in-frame context.


## v2.1.0

 - support module style( `{name,version,path}` ) style url
 - support customizing `registry` for module style url


## v2.0.1

 - mutex to prevent re-entrance of `load` function between simultaneously multiple calls.


## v2.0.0

 - dont pollute global scope with context call since we can't store global scope when context calls overlap.
 - remove dependency to `@loadingio/ldquery`


## v1.1.8

 - remove unused function `_wrapper` and rename `_wrapper-alt` to `_wrapper`.
 - hide global libraries temporarily if we are going to load them in rescope.


## v1.1.7

 - add caching feature


## v1.1.6

 - make position of delegator iframe to top left 0 to prevent from visual impact of the host document.


## v1.1.5

 - make position of delegator iframe absolute to prevent from visual impact of the host document.


## v1.1.4

 - track window injection and ignore injected members from capturing in context.
 - keep window properties from iframe at initial time


## v1.1.3

 - update dist folder


## v1.1.2

 - merge local window and global window by prototype chain and `hasOwnPropery` checking, so we can both
   - check custom members from libraries.
   - provide access to window native members for libraries.


## v1.1.1

 - correctly handling promise in recursive `load` call.
 - load variables both into local scope and global scope in wrapper.
 - force global related variables in wrapper to `this`. may lead to some unwanted issue if libraries access
 - restore global session by iterating the correct object.


## v1.1.0

 - add support to loading with custom context. this is useful with multiple stages loading.


## v1.0.0

 - upgrade packages and fix vulnerabilities
 - rewrite the entire module - wrap libraries in scope to prevent failure when running asynchronous task inside library context.


## v0.2.2

 - bug fix: rejection during loading failure should be passed to rejection callback.


## v0.2.1

 - bug fix: if context function return Promise, we should wait until it resolve to discharge scope.
   - add `until-resolve` parameter in `context` for enabling this.
   - this is only for script loading procedure. 
 - add random name in delegator for identifying current scope.


## v0.2.0

 - in context, passing only the loaded libraries instead of the whole global object to callback function.


## v0.1.0

 - by default use `delegate`. calculate imported variables with `delegate`.
 - add `useDelegateLib` option for original `delegate` effect.
