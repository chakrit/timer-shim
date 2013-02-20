
require('coffee-script');

timer = require('../src/timer-shim.coffee');
assert = require('assert');
repeatThreeSeconds = require('./code');

timer.pause();

var count = 0;
repeatThreeSeconds(function() { ++count; });

timer.wind(1000);
assert(count === 1);
timer.wind(1000);
assert(count === 2);
timer.wind(1000);
assert(count === 3);

timer.resume();

console.log("everything's ok.");

