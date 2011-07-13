vows = require 'vows'
assert = require 'assert'

vows.describe('Something')
.addBatch
  'Something':
    topic: -> 0
    'else': (n) ->
      assert.equal n, 1
    'other': (n) ->
      assert.equal n, 0
.export module