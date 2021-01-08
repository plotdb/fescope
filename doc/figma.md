# summary about the Figma plugin experiment

goal: support plugin.

## attempt 1 - iframe

 - have to duplicate document in iframe.
   - user may update document by api which may have side effect
   - document syncing may be slow
   - thus need document processing logic in iframe side, which takes too long and may affect core logic.
 - need async / await between sync
   - not friendly since TA is designer

## attempt 2 - js interpreter to wasm

try running in main thread by hiding global:

 - may hang the main thread. ( considered a not-harmful-situation since plugins run with explicitly user action )
 - hide global to prevent:
   - can fetch api in host server.
   - can modify global state.

hide global is hard - so try using js interpreter:
 - resources:
   - duktape - https://github.com/svaarala/duktape
   - test262 - https://github.com/tc39/test262/tree/es5-tests
   - alternative -https://bellard.org/quickjs/
 - pros: no access to browser api
 - cons:
   - need js interpreter wasm to be compiled.
   - slower since we need interpreting plugin
   - harder to debug if without console porting.
   - with duktape, it's only ES5. ( check quickjs )


## attempt 3 - realm shim

realm aka evaluate js in a isolated global.
 - realm.shim use Proxy Object + with() to polyfill this.
 - yet we still need some global variables like Object.
 - and with real.shim Object lead to ({}).constructor, lead to Global
 - so realm.shim overwrite all these from an iframe, so those exposed Global go to iframe.
   - additionally, we may still need many to give to plugins - so we give them the ability to make their own iframe.
   - now iframe serves for 2 purposes:
     - mimic main window Global vars.
     - provide scoped, secure browser APIs.
   - ... and communicate with message passing.
 - API should all wrapped in iframe objects, including their return values
   - this is just to broad.
   - use duktape + wasm to pass data, in turns figma api accessed throught duktape + wasm. limit the surface of attack.
 - still with vm as a backup plan in case of realm.shim is vulnerable.

## Afterward

followups: https://www.figma.com/blog/an-update-on-plugin-security/

 - realm.shim does have vulnerability:
   - https://agoric.com/realms-shim-security-updates/
 - discard realm-shim and use quickjs instead.

realm.shim is then stopped being invested by its owner Algoric: 
 - https://github.com/Agoric/realms-shim/issues/307
 - also check: https://github.com/Agoric/SES-shim for secure ecmascript.
