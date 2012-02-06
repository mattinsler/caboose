caboose_model = require 'caboose-model'
Model = caboose_model.Model
Query = caboose_model.Query

Query::paginate = (opts, callback) ->
  opts.page_size ?= 10
  opts.page ?= 1
  @skip(opts.page_size * (opts.page - 1)).limit(opts.page_size).array(callback)

Model.paginate = (opts, callback) ->
  new Query(this).paginate(opts, callback)
