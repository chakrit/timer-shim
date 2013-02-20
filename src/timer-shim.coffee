
# timer-shim.coffee - Main timer shim exports
module.exports = do ->

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
    return task


  # main timer interface
  class Timer
    paused: false
    tasks: null

    constructor: ->
      @tasks = []
      bindAll this, Timer

    timeout: taskFactoryFor TimeoutTask
    interval: taskFactoryFor IntervalTask

    clear: (task) ->
      task.cancel()

    pause: ->
      task.pause() for task in @tasks
      @paused = true

    resume: ->
      task.resume() for task in @tasks
      @paused = false

    wind: (time) ->
      task.wind time for task in @tasks


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

