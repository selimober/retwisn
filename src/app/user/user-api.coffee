class UserAPI
  constructor: (@userService) ->

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

module.exports = UserAPI

