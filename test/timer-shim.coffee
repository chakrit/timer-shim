
# test/timer-shim.coffee - Timer shim tests
do ->

  FILE = '../src/timer-shim.coffee'
  if process.env.COVER
    FILE = '../lib-cov/timer-shim.js'

  assert = require 'assert'
  { stub, spy } = require 'sinon'

  # prototype infections
  require('chai').should()
  String::s = -> this.split ','

  # shared tests
  badAction = -> throw new Error 'function should not have been called'

  itShouldHandleArgsWell = ->
    it 'should complains if timeout is not a number', ->
      (=> @call NaN).should.throw /timeout/
      (=> @call +Infinity).should.throw /timeout/
      (=> @call -Infinity).should.throw /timeout/

    it 'should complains if action is not a function', ->
      (=> @call 100, { }).should.throw /action/

    it 'should *not* complains if argument is swapped', ->
      (=> @call (->), 100).should.not.throw()

    it 'should returns timeout handle', (done) ->
      handle = @call 1, badAction
      @timer.clear handle
      setTimeout done, 10

  itShouldHaveAliases = (name, aliases) ->
    it "should be aliased as #{aliases.join ', '}", ->
      stub @klass::, name

      for alias in aliases
        @timer[alias]()
        @klass::[name].should.have.been.called
        @klass::[name].reset()

      @klass::[name].restore()


  describe 'Timer shim', ->
    beforeEach ->
      @timer = require FILE
      @klass = @timer.Timer
    afterEach ->
      delete @timer
      delete @klass

    it 'should be exported', ->
      @timer.should.be.an 'object'

    it 'should also exports Timer class', ->
      @timer.should.have.property 'Timer'
      @timer.Timer.should.be.a 'function'

    it 'should be instance of the exported Timer class', ->
      @timer.should.be.instanceof @timer.Timer

    describe 'clear() method', ->
      it 'should be exported', ->
        @timer.should.respondTo 'clearTimeout'

      itShouldHaveAliases 'clear', 'c,ct,cto,clear,clearTimeout,clearInterval'.s()

      it 'should clears timeout handle', (done) ->
        @timer.clear @timer.timeout badAction, 1
        setTimeout done, 10

    describe 'clearAll() method', ->
      it 'should be exported', ->
        @timer.should.respondTo 'clearAll'

      it 'should clears all timeout handles', (done) ->
        @timer.timeout badAction, 1
        @timer.interval badAction, 1

        setTimeout done, 10
        @timer.clearAll()

    describe 'timeout() method', ->
      before -> @call = -> @timer.t.apply @timer, arguments
      after -> delete @call

      it 'should be exported', ->
        @timer.should.respondTo 'timeout'

      itShouldHandleArgsWell()
      itShouldHaveAliases 'timeout', 't,to,timeout,setTimeout'.s()

      it 'should works like setTimeout', (done) ->
        @call 1, -> done() # mocha will complain for multiple calls

    describe 'interval() method', ->
      before -> @call = -> @timer.i.apply @timer, arguments
      after -> delete @call

      it 'should be exported', ->
        @timer.should.respondTo 'interval'

      itShouldHandleArgsWell()
      itShouldHaveAliases 'interval', 'i,in,iv,inv,setInterval'.s()

      it 'should works like setInterval', (done) ->
        count = 0
        handle = @call 1, =>
          if ++count is 3
            @timer.clear handle
            done()

    describe 'unref() method', ->
      before -> @unref = -> @timer.unref.apply @timer, arguments
      after -> delete @unref

      it 'should be exported', -> @unref.should.be.a 'function'

      it 'should calls unref() on all scheduled timers', (done) ->
        id = @timer.timeout 1, -> done()
        stub id, 'unref'
        @unref()
        id.unref.called.should.be.true
        id.unref.restore()

    describe 'ref() method', ->
      before -> @ref = -> @timer.ref.apply @timer, arguments
      after -> delete @ref

      it 'should be exported', -> @ref.should.be.a 'function'

      it 'should calls ref() on all scheduled timers', (done) ->
        id = @timer.timeout 1, -> done()
        spy id, 'ref'
        @ref()
        id.ref.called.should.be.true
        id.ref.restore()

