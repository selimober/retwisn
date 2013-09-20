HomeController = require '../controller/home-controller'
UserController = require '../controller/user-controller'
PostController = require '../controller/post-controller'
ApiPostController = require '../controller/api-post-controller'

module.exports = (app) ->

  provider = require('./provider')

  homeController = new HomeController
  app.get '/', homeController.get

  app.get '/timeline', (req, res) ->
    res.render 'timeline'

  userController = new UserController provider.getUserService()
  app.post '/signup', userController.createUser
  app.post '/login', userController.login
  app.get '/logout', userController.logout

  postController = new PostController provider.getPostService()
  app.get '/user/:username', postController.userPosts
  app.post '/postMessage', postController.postMessage

  # API
  apiPostController = new ApiPostController provider.getPostService()

  app.get '/api/:username/timeline', apiPostController.fetchUserTimeline
  app.get '/api/globalTimeline', apiPostController.fetchGlobalTimeline
  app.get '/api/:username/posts', apiPostController.fetchUserPosts

  app.post '/api/isFollowing', userController.isFollowing
  app.post '/api/:followingUsername/follows/:followedUsername', userController.follow
  # app.delete '/api/:followingUsername/follows/:followedUsername' userController.unFollow

  app.get '/api/:username/followedBy', userController.followers
  app.get '/api/:username/follows', userController.following
  # app.post '/api/:username/following', userController.fetchFollowingUsers
  # app.get '/api/onlineUsers', userController.fetchOnlineUsers
  app.get '/api/lastRegistredUsers', userController.lastRegistered
