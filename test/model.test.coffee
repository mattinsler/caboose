vows = require 'vows'
assert = require 'assert'

Model = require '../lib/mongo/model'
Spec = require '../lib/mongo/spec'

Foo = new Model 'test', ->
  @string 'app_id', key: 'a'
  @object 'object', key: 'o', default: {foo: 'bar'}

fixture_1 = app_id: 'hello', something: 'world'
fixture_2 = a: 'hello', s: 'world'

vows.describe('Model')
.addBatch
  'Simple filter':
    topic: -> Foo.spec.filter fixture_1
    'name should be present': (o) ->
      assert.equal o.app_id, 'hello'
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.addBatch
  'Name to key filter':
    topic: Foo.spec.filter fixture_1, Spec.nameToKey
    'key should be present': (o) ->
      assert.equal o.a, 'hello'
    'name should be undefined': (o) ->
      assert.isUndefined o.app_id
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.addBatch
  'Key to name filter':
    topic: Foo.spec.filter fixture_2, Spec.keyToName
    'name should be present': (o) ->
      assert.equal o.app_id, 'hello'
    'key should be undefined': (o) ->
      assert.isUndefined o.a
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.s
.addBatch
  'Default filter':
    topic: Foo.spec.filter fixture_1, Spec.applyDefault
    'name should be present': (o) ->
      assert.equal o.app_id, 'hello'
    'absent field should be default value': (o) ->
      assert.deepEqual o.object, {foo: 'bar'}
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.export module