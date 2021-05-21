# 1.1.0

 - add support to loading with custom context. this is useful with multiple stages loading.


# 1.0.0

 - upgrade packages and fix vulnerabilities
 - rewrite the entire module - wrap libraries in scope to prevent failure when running asynchronous task inside library context.


# 0.2.2

 - bug fix: rejection during loading failure should be passed to rejection callback.


# 0.2.1

 - bug fix: if context function return Promise, we should wait until it resolve to discharge scope.
   - add `until-resolve` parameter in `context` for enabling this.
   - this is only for script loading procedure. 
 - add random name in delegator for identifying current scope.


# 0.2.0

 - in context, passing only the loaded libraries instead of the whole global object to callback function.


# 0.1.0

 - by default use `delegate`. calculate imported variables with `delegate`.
 - add `useDelegateLib` option for original `delegate` effect.
