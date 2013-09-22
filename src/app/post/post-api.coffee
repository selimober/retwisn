class PostAPI
  constructor: (@postService) ->

  fetchGlobalTimeline: (req, res) =>
    @postService.fetchGlobalTimeline (err, replies) ->
      res.send replies

  fetchUserTimeline: (req, res) =>
    @postService.fetchUserTimeline req.params.username, (err, replies) ->
      res.send replies

  fetchUserPosts: (req, res) =>
    @postService.fetchUserTimeline req.params.username, (err, replies) ->
      replies = (post for post in replies when post.user is req.params.username)
      res.send replies

module.exports = PostAPI