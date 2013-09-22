HomeController  = require '../home/home-controller'
UserController  = require '../user/user-controller'
UserAPI         = require '../user/user-api'
PostController  = require '../post/post-controller'
PostAPI         = require '../post/post-api'

module.exports = (app) ->

  provider = require('./provider')

  # HOME - LOGIN - LOGOUT
  homeController = new HomeController
  app.get   '/', homeController.get
  app.post  '/login', homeController.login
  app.get   '/logout', homeController.logout

  # USER
  userController = new UserController provider.getUserService()
  app.post  '/signup', userController.createUser
  app.post  '/api/:followingUsername/follows/:followedUsername', userController.follow

  userAPI = new UserAPI provider.getUserService()
  app.post  '/api/isFollowing', userAPI.isFollowing
  app.get   '/api/:username/followedBy', userAPI.followers
  app.get   '/api/:username/follows', userAPI.following
  app.get   '/api/lastRegistredUsers', userAPI.lastRegistered

  # POST
  app.get   '/timeline', (req, res) ->
    res.render 'timeline'

  postController = new PostController provider.getPostService()
  app.get   '/user/:username', postController.userPosts
  app.post  '/postMessage', postController.postMessage

  postAPI = new PostAPI provider.getPostService()
  app.get   '/api/:username/timeline', postAPI.fetchUserTimeline
  app.get   '/api/globalTimeline', postAPI.fetchGlobalTimeline
  app.get   '/api/:username/posts', postAPI.fetchUserPosts
