module.exports = (req, res, next) ->
  req.session.resetCounter = Date.now()
  path = req.path
  if path is "" or path is "/" or path is "/login" or path is "/signup"
    next()
  else
    if req.session.username?
      next()
    else
      req.flash 'error', 'Session expired or never authenticated'
      res.redirect '/'