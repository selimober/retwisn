redirectError = (req, res, path, message) ->
  req.flash 'error', message
  res.redirect path

class UserController
  constructor: (@userService) ->

  createUser: (req, res) =>
    username = req.body.username
    password = req.body.password

    if not (username?.length and password?.length)
      redirectError req, res, '/', "Username and password cannot be empty"
    else
      @userService.createUser username, password, (err, user) ->
        if err?
          redirectError req, res, '/', err.message
        else
          req.session.username = username
          req.flash 'info', "User created"
          res.redirect '/timeline'

  login: (req, res) =>
    username = req.body.username
    password = req.body.password

    if not (username?.length and password?.length)
      redirectError req, res, '/', "Username and password cannot be empty"
    else
      @userService.login username, password, (err) ->
        if err?
          redirectError req, res, '/', err.message
        else
          req.session.username = username
          res.redirect '/timeline'

  logout: (req, res) =>
    req.session.destroy (err) ->
      res.redirect '/'

  follow: (req, res) =>
    followingUsername = req.params.followingUsername
    followedUsername = req.params.followedUsername

    if not (followingUsername?.length and followedUsername?.length)
      redirectError req, res, '/timeline', "Username empty"
    else
      @userService.follow followingUsername, followedUsername, (err) ->
        if err?
          redirectError req, res, '/timeline', err.message
        else
          res.redirect '/timeline'

  followers: (req, res) =>
    @userService.fetchFollowers req.params.username, (err, followers) ->
      res.send followers

  following: (req, res) =>
    @userService.fetchFollowings req.params.username, (err, followings) ->
      res.send followings

  isFollowing: (req, res) =>
    followingUser = req.body.followingUser
    followedUser = req.body.followedUser
    @userService.isFollowing followingUser, followedUser, (err, reply) ->
      res.send {isFollowing: reply}

  lastRegistered: (req, res) =>
    @userService.lastRegistered (err, reply) ->
      res.send reply


module.exports = UserController