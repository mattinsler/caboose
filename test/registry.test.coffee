vows = require 'vows'
assert = require 'assert'

Registry = require '../lib/server/registry'
registry = new Registry()

vows.describe('Registry')
.addBatch
  'split by capital':
    topic: -> registry.split 'ApplicationController'
    'should be an array': (o) ->
      assert.isTrue Array.isArray(o)
    'should have 2 parts': (o) ->
      assert.equal o.length, 2
    'should have split words': (o) ->
      assert.equal o[0], 'application'
      assert.equal o[1], 'controller'
  'split by underscore':
    topic: -> registry.split 'application_controller'
    'should be an array': (o) ->
      assert.isTrue Array.isArray(o)
    'should have 2 parts': (o) ->
      assert.equal o.length, 2
    'should have split words': (o) ->
      assert.equal o[0], 'application'
      assert.equal o[1], 'controller'
.export module