
# TIMER-SHIM

> All problems in computer science can be solved by another level of indirection

TIMER-SHIM is a simple wrapper around standard timer functions which allows you to stub / test / fake their call and timing function without resorting to tricky global setTimeout/setInterval override.

If you have trouble getting mocha and sinon fake timers to behave, you might find this simple module useful.

Additionally, TIMER-SHIM also provides a few niceties over standard timer functions, including:

* Call with timeout number before the function.
* Shorter and simpler aliases without any magic or prototype infection.
* Validates against NaN and non-function values to save you debugging time.

At its core, it simply delegates the calls to setTimeout/setInterval internally but by calling those function via TIMER-SHIM you can more easily test your time-dependent code.

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

# SAMPLE MOCHA/SINON-CHAI TEST STUBBING

Write your code using the timer module like this:

```js
var timer = require('timer-shim');

function testWithTimeout() {
  // complicated timeout code
  internalState = false
  timer.timeout(100, function() {
    // more complicated code
    internalState = true
  });
}
```

Then write your test like this:

```js
var timer = require('timer-shim');

describe('timer functionality', function() {
  it('should works', function() {
    sinon.stub(timer, 'timeout').callsArg(1)

    testWithTimeout();
    timer.timeout.should.have.been.calledWith(100);
    interalState.should.be.true

    timer.timeout.restore();
  });
});
```

# API

`timer.c`  
`timer.ct`  
`timer.cto`  
`timer.clear`  
`timer.clearTimeout`  
Clears the timeout handle given.

`timer.t`  
`timer.to`  
`timer.timeout`  
`timer.setTimeout`  
Sets a function to run after the specified timeout

`timer.i`  
`timer.in`  
`timer.iv`  
`timer.setInterval`  
Sets a function to repeatedly every set interval.

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
$ npm install -d && make test
```

Compiles with:

```sh
$ npm install -d && make lib/timer-shim.js
```

#### TODOs

* Ability to fast-forward timers ala sinon fake timers.
* Ability to infect global setTimeout/setInterval and route it to call the shim functions instead.

# LICENSE

BSD

# SUPPORT

Just open a GitHub issue or ping me [@chakrit](http://twitter.com/chakrit) on Twitter.

