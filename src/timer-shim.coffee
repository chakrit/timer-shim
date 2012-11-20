
# timer-shim.coffee - Main timer shim exports
module.exports = do ->

  # utils
  alias = (klass, names..., action) ->
    klass::[name] = action for name in names

  validate = (timeout, action) ->
    [action, timeout] = [timeout, action] if typeof action is 'number'
    throw new Error('timeout is not a valid number') unless isFinite(timeout)
    throw new Error('action is not a function') unless typeof action is 'function'

    return [timeout, action]


  # timer class
  class Timer

  alias Timer, 't,to,timeout,setTimeout'.split(',')...,
    (timeout, action) ->
      [timeout, action] = validate timeout, action
      setTimeout action, timeout

  alias Timer, 'c,ct,cto,clear,clearTimeout'.split(',')...,
    (handle) ->
      clearTimeout handle

  alias Timer, 'i,in,iv,interval,setInterval'.split(',')...,
    (timeout, action) ->
      [timeout, action] = validate timeout, action
      setInterval action, timeout


  # exports
  timer = new Timer()
  Timer::Timer = Timer
  return timer

