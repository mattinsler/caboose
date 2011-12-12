Model = require 'caboose-model'

Post = Model.create('Post')
            .store_in('post')

module.exports = Post.build()
