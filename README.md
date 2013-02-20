
# TIMER-SHIM

> All problems in computer science can be solved by another level of indirection

TIMER-SHIM is a simple wrapper around standard timer functions adding the ability to mock
/ stub / test timing functions with ease.

If you have trouble getting mocha and sinon fake timers to behave, or you have trouble
testing code that depends on `setTimeout` and/or `setInterval` you will find this simple
comes in quite handy.

Additionally, TIMER-SHIM also provides a few niceties over standard timer functions,
including:

* Call with timeout number before the function (or vice versa - doesn't matter.)
* Shorter and simpler aliases without any magic or prototype infection.
* Protect against NaN and non-function values to save you debugging time.

And best of all:

* Provides `pause()`, `resume()` and `wind()` so you can test your timing functionality
  directly in a sane way.

At its core, the shim simply delegates calls to `setTimeout`/`setInterval` internally but
by calling those function via TIMER-SHIM you can more easily test your time-dependent
code.

There is a little caveat though, as I try not to pollute your global namespace in that you
must update all your `setTimeout` and `setInterval` to use TIMER-SHIM's provided functions
instead to be able to use the time simulation functions.

# INSTALL

```sh
$ npm install timer-shim --save
```

# USE

```js
var timer = require('timer-shim')
  , count = 0
  , handle = null;

timer.timeout(50, function() { console.log('hello!'); });

handle = timer.interval(100, function() {
  console.log(count++);
  if (count === 10) timer.clear(handle);
});
```

See `example/code.js` and `example/test.js` for an example on how to write code / test the
code.

# API

`timer.Timer`  
Internal class for handling timers. Instances exports the same API as the module itself.
You can create multiple instances of this class if you need to `pause()`, `resume()` and
`wind()` only a certain set of functions while leaving other set of functions still
working normally.

`timer.c`  
`timer.ct`  
`timer.cto`  
`timer.clear`  
`timer.clearTimeout`  
`timer.clearInterval`  
Clears the timeout handle given. Only works with TIMER-SHIM's provided handles. Does not
works with handles returned from native `setTimeout` or `setInterval`.

`timer.t`  
`timer.to`  
`timer.timeout`  
`timer.setTimeout`  
Schedules a function to run after the specified timeout. Returns a TIMER-SHIM handle.

`timer.i`  
`timer.in`  
`timer.iv`  
`timer.inv`  
`timer.interval`  
`timer.setInterval`  
Schedules a function to run repeatedly every set interval. Returns a TIMER-SHIM handle.

`timer.pause`  
Pauses all timing functions that has not yet run and all functions that may be scheduled
in the future.

`timer.resume`  
Resumes all scheduled function as though the time hasn't flickered.

`timer.wind( time )`  
Only works when paused. Winds the internal clock by the specified `time` (in ms) running
anything that is scheduled to be run in that amount of time. `resume()`-ing after this
point will execute any scheduled functions as though `time` has passed (i.e. shorter
timeout, shorter first invocation of interval function)

# OVERLOADS

Both `timer.timeout` and `timer.interval` can be called in either of the following ways:

```js
timer.timeout(100, function() { }); // both works
timer.timeout(function() { }, 100);

timer.interval(100, function() { }); // also works
timer.interval(function() { }, 100);
```

# DEVELOPMENT

Test with:

```sh
make test
```

Compiles with:

```sh
$ make lib/timer-shim.js
```

#### TODOs

* Ability to infect global setTimeout/setInterval and route it to call the shim functions
  instead.
* Performance optimizations.
* nextTick support?

# LICENSE

BSD

# SUPPORT

Just open a GitHub issue or ping me [@chakrit](http://twitter.com/chakrit) on Twitter.

