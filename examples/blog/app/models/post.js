var Model = require('caboose-model');

var Post = Model.create('Post')
                .store_in('post');

module.exports = Post.build();
