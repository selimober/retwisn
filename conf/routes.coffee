HomeController = require '../controller/home-controller'
UserController = require '../controller/user-controller'

module.exports = (app) ->
  provider = require('../provider')(app)

  homeController = new HomeController
  app.get '/', homeController.get

  userController = new UserController provider.getUserService()
  app.post '/user', userController.createUser