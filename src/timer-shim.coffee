
# timer-shim.coffee - Main timer shim exports
module.exports = do ->

  # Configuration
  # TODO: Make configurable
  INITIAL_THRESHOLD = 10
  CLEAN_THRESHOLD = 1.10


  # speed up removals with linkedlist
  LinkedList = require 'linkedlist'

  LinkedList::remove = (ll, item) ->
    ll.resetCursor()
    while ll.next() and item isnt ll.current
      ; # no-op

    return false if ll.current isnt item

    ll.removeCurrent()
    return true

  # utils
  alias = (Klass, action, names) ->
    for name in names
      Klass::[name] = ->
        Klass::[action].apply this, arguments

  bindAll = (obj, klass) -> # custom bind cause coffee binders can't be used in alias()
    for key of klass::
      if typeof klass::[key] is 'function' and not obj.hasOwnProperty key
        do (key) -> obj[key] = -> klass::[key].apply obj, arguments

  validate = (timeout, action) ->
    [action, timeout] = [timeout, action] if typeof action is 'number'
    throw new Error 'timeout is not a valid number' unless isFinite timeout
    throw new Error 'action is not a function' unless typeof action is 'function'

    return [timeout, action]


  # internal Task class for handling each timeout jobs as a single unit
  class Task
    constructor: (time, action) ->
      @id = null
      @time = time
      @action = action
      @paused = true # start paused
      @canceled = false
      @windedTime = 0

    cancel: ->
      @canceled = true
      return @_pause()

    pause: ->
      return if @canceled or @paused
      @_pause()
      @id = null

      @paused = true
      @windedTime = 0

    resume: ->
      return if @canceled or not @paused
      @id = @_resume @windedTime

      @paused = false
      @windedTime = 0

    wind: (time) ->
      return if @canceled or not @paused

      @windedTime += time
      @windedTime = @_wind @windedTime

    unref: ->
      return unless @id and typeof @id.unref is 'function'
      @id.unref()

    ref: ->
      return unless @id and typeof @id.ref is 'function'
      @id.ref()

    _pause: -> throw new Error 'must be overridden'
    _resume: -> throw new Error 'must be overridden'


  class IntervalTask extends Task
    _pause: -> clearInterval @id
    _resume: (time) ->
      unless time
        setInterval @action, @time
      else
        setTimeout => # shorten first action after a wind()
          @action()
          @id = setInterval @action, @time
        , @time - time

    _wind: (time) ->
      while time >= @time
        time -= @time
        @action()

      return time

  class TimeoutTask extends Task
    _pause: -> clearTimeout @id
    _resume: (time) -> setTimeout @action, @time - time
    _wind: (time) ->
      return time if time < @time

      @action()
      @canceled = true
      return 0


  taskFactoryFor = (Klass) -> (timeout, action) ->
    [timeout, action] = validate timeout, action
    task = new Klass timeout, action

    @tasks.push task
    task.resume() unless @paused

    @_checkAndClean()
    return task


  # main timer interface
  class Timer
    paused: false
    tasks: null
    _lastCleanedLength: 0

    constructor: ->
      @tasks = new LinkedList
      @_lastCleanedLength = INITIAL_THRESHOLD

      bindAll this, Timer

    timeout: taskFactoryFor TimeoutTask
    interval: taskFactoryFor IntervalTask

    clear: (task) ->
      task.cancel()

    clearAll: () ->
      @tasks.resetCursor()
      while @tasks.next()
        @clear @tasks.current

      @tasks = new LinkedList

    pause: ->
      @tasks.resetCursor()
      @tasks.current.pause() while @tasks.next()
      @paused = true

    resume: ->
      @tasks.resetCursor()
      @tasks.current.resume() while @tasks.next()
      @paused = false

    wind: (time) ->
      @tasks.resetCursor()
      @tasks.current.wind time while @tasks.next()

    unref: ->
      @tasks.resetCursor()
      @tasks.current.unref() while @tasks.next()

    ref: ->
      @tasks.resetCursor()
      @tasks.current.ref() while @tasks.next()

    _checkAndClean: ->
      return unless @tasks.length > @_lastCleanedLength * CLEAN_THRESHOLD

      @tasks.resetCursor()
      while @tasks.next() when @tasks.current.canceled
        @tasks.removeCurrent()

      @_lastCleanedLength = @tasks.length


  ALIASES =
    'timeout'   : 't,to,setTimeout'
    'clear'     : 'c,ct,cto,clearTimeout,clearInterval'
    'interval'  : 'i,in,iv,inv,setInterval'

  for key, aliases of ALIASES
    alias Timer, key, aliases.split ','

  # exports
  timer = new Timer()
  Timer::Timer = Timer
  return timer

