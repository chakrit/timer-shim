
# timer-shim.coffee - Main timer shim exports
module.exports = do ->

  # utils
  alias = (klass, names, action) ->
    names = names.split ','
    klass::[name] = action for name in names

  validate = (timeout, action) ->
    [action, timeout] = [timeout, action] if typeof action is 'number'
    throw new Error('timeout is not a valid number') unless isFinite(timeout)
    throw new Error('action is not a function') unless typeof action is 'function'

    return [timeout, action]


  # timer class
  class Timer


  alias Timer, 'n,nt,tick,nexttick,nextTick',
    (action) ->
      throw new Error('action is not a function') unless typeof action is 'function'

      if process and process.nextTick
        process.nextTick action
      else
        setTimeout action, 0

  alias Timer, 't,to,timeout,setTimeout',
    (timeout, action) ->
      [timeout, action] = validate timeout, action
      setTimeout action, timeout

  alias Timer, 'c,ct,cto,clear,clearTimeout',
    (handle) ->
      clearTimeout handle

  alias Timer, 'i,in,iv,interval,setInterval',
    (timeout, action) ->
      [timeout, action] = validate timeout, action
      setInterval action, timeout


  # exports
  timer = new Timer()
  Timer::Timer = Timer
  return timer

