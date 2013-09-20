class PostController
  constructor: (@postService) ->

  userPosts: (req, res) =>
    res.locals.username = req.params.username
    res.render 'user'

  postMessage: (req, res) =>
    @postService.post req.session.username, req.body.message, (err, pid) ->
      if err?
        req.flash 'error', err.message
      res.redirect 'timeline'

module.exports = PostController
