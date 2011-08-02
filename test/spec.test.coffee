Spec = require '../lib/model/spec'
core_types = require('../plugins/core_types/models').compiler.scope
Document = core_types.Document
Int32 = core_types.Int32
String = core_types.String

spec = new Spec fields: [
  {name: 'username', key: 'u', type: String},
  {name: 'password', key: 'p', type: String},
  {name: 'age', key: 'a', type: Int32},
  {name: 'blob', key: 'b', type: Document, default: {hello: 'world'}}
  {name: 'stats', key: 's', type: Document, spec: new Spec [
    {name: 'login_count', key: 'i', type: Int32, default: 0},
    {name: 'logout_count', key: 'o', type: Int32, default: 0},
    {name: 'like_count', key: 'l', type: Int32, default: 0}
  ]}
]

console.log spec.to_plain {username: 'mattinsler', password: 'password', blob: {foo: 'bar'}, stats: {login_count: 4}, foo: 'bar'}
console.log spec.to_plain {username: 'mattinsler', password: 'password'}

console.log spec.to_query {username: /^matt/, age: {$gte: 18}, 'stats.login_count': 4, $set: {'blob.foo.bar': 8}}