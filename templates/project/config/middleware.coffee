module.exports = (http) ->
  http.use express.bodyParser()
  http.use express.methodOverride()
  http.use express.cookieParser()
  http.use express.session(secret: 'some kind of random string')
  http.use -> Caboose.app.router.route.apply(Caboose.app.router, arguments)
  http.use express.static path.join(Caboose.root, 'public')
