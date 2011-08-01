vows = require 'vows'
assert = require 'assert'

Model = require '../lib/model/model'
Spec = require '../lib/model/spec'

ModelCompiler = require '../lib/model/model_compiler'
compiler = new ModelCompiler()

Foo = compiler.compile "class Foo extends Model\n
  string 'app_id', key: 'a'\n
  string 'no_key'\n
  object 'object', key: 'o', default: {foo: 'bar'}\n
"

fixture_1 = app_id: 'hello', no_key: 'boo', something: 'world'
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
    topic: Foo.spec.filter fixture_1, Spec.NameToKey
    'key should be present': (o) ->
      assert.equal o.a, 'hello'
    'name should be undefined': (o) ->
      assert.isUndefined o.app_id
    'names without keys should be present': (o) ->
      assert.equal o.no_key, 'boo'
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.addBatch
  'Key to name filter':
    topic: Foo.spec.filter fixture_2, Spec.KeyToName
    'name should be present': (o) ->
      assert.equal o.app_id, 'hello'
    'key should be undefined': (o) ->
      assert.isUndefined o.a
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.s
.addBatch
  'Default filter':
    topic: Foo.spec.filter fixture_1, Spec.ApplyDefault
    'name should be present': (o) ->
      assert.equal o.app_id, 'hello'
    'absent field should be default value': (o) ->
      assert.deepEqual o.object, {foo: 'bar'}
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.addBatch
  'Default filter & name to key':
    topic: Foo.spec.filter fixture_1, Spec.ApplyDefault, Spec.NameToKey
    'name should be present': (o) ->
      assert.equal o.a, 'hello'
    'absent field should be default value': (o) ->
      assert.deepEqual o.o, {foo: 'bar'}
    'unknown fields should be undefined': (o) ->
      assert.isUndefined o.something
.export module