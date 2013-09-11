sendError = (res, status, renderLocation, errorMessage) ->
  res.status(status).render renderLocation, {
    status: 'ERROR'
    message: errorMessage
  }

class UserController
  constructor: (@userService) ->

  createUser: (req, res) =>
    username = req.param.username
    password = req.param.password

    if not (username?.length and password?.length)
      sendError res, 400, '/home', "Username and password cannot be empty"
    else
      @userService.createUser username, password, (err, user) ->
        if err?
          sendError res, 400, '/home', err.message
        else
          res.render '/home', {
            status: 'OK'
            message: 'User created'
          }

  login: (req, res) =>
    username = req.param.username
    password = req.param.password

    if not (username?.length and password?.length)
      sendError res, 400, '/home', "Username and password cannot be empty"
    else
      @userService.login username, password, (err, authString) ->
        if err?
          sendError res, 400, '/home', err.message
        else
          settings = req.app.get 'settings'
          cookieName = settings.app.authCookieName
          domain = settings.app.domain
          res.cookie cookieName, authString, {domain: ".#{domain}", 'Max-Age': settings.app.authCookieMaxAge}
          res.redirect '/timeline'

  follow: (req, res) =>
    followingUsername = req.loggedInUsername
    followedUserName = req.param.followedUserName

    if not (followingUsername?.length and followedUserName?.length)
      sendError res, 400, '/timeline', "Username empty"
    else
      @userService.follow followingUsername, followedUserName, (err) ->
        if err?
          sendError res, 400, '/timeline', err.message
        else
          res.redirect '/timeline'


module.exports = UserController