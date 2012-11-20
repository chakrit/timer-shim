
# test/timer-shim.coffee - Timer shim tests
do ->

  # use file with coverage information on cover mode
  FILE = '../src/timer-shim.coffee'
  if process.env.COVER
    FILE = '../lib-cov/timer-shim.js'

  # infect prototype for simpler tests
  assert = require 'assert'
  require('chai').should()
  String::s = -> this.split ','

  # helper funcs
  badAction = ->
    throw new Error('function should not have been called')

  assertAliases = (obj, aliases) ->
    for name in aliases
      obj.should.respondTo name
      assert obj[name] is obj[aliases[0]]


  # shared tests
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
      clearTimeout handle
      setTimeout done, 10


  describe 'Timer shim', ->
    beforeEach -> @timer = require(FILE)
    afterEach -> delete @timer

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

      it 'should be aliased as c, ct, cto, clear and clearTimeout', ->
        assertAliases @timer, 'c,ct,cto,clear,clearTimeout'.s()

      it 'should clears timeout handle', (done) ->
        @timer.c (setTimeout badAction, 1)
        setTimeout done, 10


    describe 'timeout() method', ->
      before -> @call = -> @timer.t.apply @timer, arguments
      after -> delete @call

      it 'should be exported', ->
        @timer.should.respondTo 'timeout'

      it 'should be aliased as t, to, timeout and setTimeout', ->
        assertAliases @timer, 't,to,timeout,setTimeout'.s()

      itShouldHandleArgsWell()

      it 'should works like setTimeout', (done) ->
        @call 1, done # mocha will complain for multiple calls


    describe 'interval() method', ->
      before -> @call = -> @timer.i.apply @timer, arguments
      after -> delete @call

      it 'should be exported', ->
        @timer.should.respondTo 'interval'

      it 'should be aliased as i, in, iv, interval and setInterval', ->
        assertAliases @timer, 'i,in,iv,interval,setInterval'.s()

      itShouldHandleArgsWell()

      it 'should works like setInterval', (done) ->
        count = 0
        handle = @call 1, =>
          if ++count is 3
            clearTimeout handle
            done()

