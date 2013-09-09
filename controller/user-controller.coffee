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
          res.cookie 'auth', authString, {domain: '.localhost', expires: new Date(Date.now() + 3600)}
          res.redirect '/timeline'



module.exports = UserController