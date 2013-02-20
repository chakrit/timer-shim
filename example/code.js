
require('coffee-script');

timer = require('../src/timer-shim.coffee');

function repeatThreeSeconds(action) {
  var count = 0;

  function repeater() {
    action(count);

    if (++count === 3) return;
    timer.timeout(1000, repeater);
  }

  timer.timeout(1000, repeater);
}

module.exports = repeatThreeSeconds;

if (module === require.main) {
  repeatThreeSeconds(function(second) {
    console.log('second #' + second);
  });
}

