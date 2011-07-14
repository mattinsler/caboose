module.exports = class Route
  

class IndexController extends Controller
  index: ->
    @timestamp = new Date()
    render()
  
@app.get '/', (req, res, next) ->
  controller = new IndexController()
  controller.index()