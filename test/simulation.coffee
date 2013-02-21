
# test/simulation.coffee - Simulation tests
do ->

  FILE = '../src/timer-shim.coffee'
  if process.env.COVER
    FILE = '../lib-cov/timer-shim.js'

  assert = require 'assert'
  { stub, spy } = require 'sinon'

  # prototype infections
  require('chai').should()
  String::s = -> this.split ','

  # test util
  badAction = -> throw new Error 'function should *not* have been called'

  forEachTimeoutMethod = (actions) ->
    actions method for method in ['timeout', 'interval']


  describe 'Timer shim with time simulation', ->
    beforeEach ->
      @timerShim = require FILE
      @klass = @timerShim.Timer
      @timer = new @klass
    afterEach ->
      delete @timer
      delete @klass
      delete @timerShim

    it 'should exports `paused` property that is initially false', ->
      @timer.should.have.property 'paused'
      @timer.paused.should.be.false

    it 'should exports `tasks` property that is initially empty', ->
      @timer.should.have.property 'tasks'
      @timer.tasks.should.have.length 0

    describe 'clear() method', ->
      beforeEach -> @clear = @timer.clear
      afterEach -> delete @clear

      it 'should be exported', ->
        @clear.should.be.a 'function'

      forEachTimeoutMethod (method) ->
        it "should cancel action queud via #{method}()", (done) ->
          handle = @timer[method] 1, badAction
          @timer.clear handle
          setTimeout done, 10

    describe 'pause() method', ->
      beforeEach -> @pause = @timer.pause
      afterEach -> delete @pause

      it 'should be exported', ->
        @pause.should.be.a 'function'

      it 'should sets paused property to true', ->
        @pause()
        @timer.paused.should.be.true

      forEachTimeoutMethod (method) ->
        it "should pauses action queued via #{method}()", (done) ->
          handle = @timer[method] 1, badAction
          @timer.pause()

          setTimeout =>
            @timer.clear handle
            done()
          , 10

        it 'should pauses further action queued via timeout()', (done) ->
          @timer.pause()
          handle = @timer[method] 1, badAction

          setTimeout =>
            @timer.clear handle
            done()
          , 10

    # NOTE: Due to a strange mocha bug, if we place the wind() method after resume()
    #   method tests, some beforeEach block will run out of order producing setups and
    #   teardowns in incorrect order.
    describe 'wind() method', ->
      beforeEach -> @wind = @timer.wind
      afterEach -> delete @wind

      it 'should be exported', -> @wind.should.be.a 'function'

      describe 'when in normal state', ->
        forEachTimeoutMethod (method) ->
          it "should *not* have any effect to normal #{method}() calls.", (done) ->
            bad = @timer[method] 1000, badAction
            @timer.wind 9999

            setTimeout =>
              @timer.clear bad
              done()
            , 10

      describe 'when in paused state', ->
        beforeEach -> @timer.pause()

        forEachTimeoutMethod (method) ->
          it "should *not* causes actions queued via #{method}() to run if timeout is lower than action timeout", (done) ->
            bad = @timer[method] 2, badAction
            @timer.wind 1
            setTimeout =>
              @timer.clear bad
              done()
            , 10

          it "should causes actions queued via #{method}() to run if timeout equals action timeout", (done) ->
            good = @timer[method] 10, =>
              @timer.clear good
              done()

            @timer.wind 10

          it "should causes action queued via #{method}() to run if timeout is higher than action timeout", (done) ->
            good = @timer[method] 10, =>
              @timer.clear good
              done()

            @timer.wind 15

          it "should causes action queued via #{method}() to be invalidated after resume() if timeout is higher than action timeout", (done) ->
            didFinish = false
            good = @timer[method] 1, =>
              unless didFinish
                @timer.clear good
                setTimeout done, 10
                didFinish = true
              else
                badAction()

            @timer.wind 1
            @timer.resume()

        describe 'resume()-ing after a wind()', ->
          forEachTimeoutMethod (method) ->
            it "should resume first invocation of action queued via #{method}() to with less timeout", (done) ->
              bad = setTimeout badAction, 50
              good = @timer[method] 1000, => # test timeout < 1000
                clearTimeout bad
                @timer.clear good
                done()

              @timer.wind 999
              @timer.resume()

        it 'should causes action queued via interval() to run multiple times if timeout is a multiple of action timeout', ->
          count = 0
          good = @timer.interval 1, => ++count

          @wind 3
          count.should.eq 3

        it 'should *not* causes action queued via timeout() to run multiple times if timeout is a multiple of action timeout', ->
          count = 0
          @timer.timeout 1, => ++count

          @wind 3
          count.should.eq 1

        it 'should *not* causes action queued via timeout() to run multiple times if called multiple times', ->
          count = 0
          @timer.timeout 1, => ++count

          @wind 1
          @wind 1
          @wind 1
          count.should.eq 1


    describe 'resume() method', ->
      beforeEach -> @resume = @timer.resume
      afterEach -> delete @resume

      it 'should be exported', ->
        @resume.should.be.a 'function'

      describe 'when in paused state', ->
        beforeEach -> @timer.pause()

        it 'should sets paused property to false', ->
          @resume()
          @timer.paused.should.be.false

        describe 'calling multiple times', ->
          it 'should *not* causes action registered with timeout() to run more than once', (done) ->
            counter = 0
            @timer.timeout 1, => ++counter
            @timer.resume()
            @timer.resume()

            setTimeout =>
              counter.should.eq 1 # will not be 1 if multiple timeouts were running
              done()
             , 10

          it 'should *not* causes action registered with interval() to run more than once every set interval', (done) ->
            counter = 0
            handle = @timer.interval 1, =>
              if ++counter is 3
                @timer.clear handle

            @timer.resume()
            @timer.resume()

            setTimeout =>
              counter.should.eq 3 # will not be 3 if multiple intervals were running
              done()
            , 10

        forEachTimeoutMethod (method) ->
          it "should resumes action queued via #{method}()", (done) ->
            bad = setTimeout badAction, 10
            good = @timer[method] 1, =>
              clearTimeout bad
              @timer.clear good
              done()

            @timer.resume()

          it "should restore #{method}() to work normally.", (done) ->
            @timer.resume()

            bad = setTimeout badAction, 10
            good = @timer[method] 1, =>
              clearTimeout bad
              @timer.clear good
              done()

