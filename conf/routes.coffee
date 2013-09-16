HomeController = require '../controller/home-controller'
UserController = require '../controller/user-controller'
PostController = require '../controller/post-controller'

module.exports = (app) ->

  provider = require('./provider')

  homeController = new HomeController
  app.get '/', homeController.get

  userController = new UserController provider.getUserService()
  app.post '/user', userController.createUser

  postController = new PostController provider.getPostService()
  app.get '/user/:username/timeline', postController.fetchUserTimeline
  app.post '/user/:username/post', postController.post