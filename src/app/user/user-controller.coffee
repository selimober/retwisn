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




module.exports = UserController