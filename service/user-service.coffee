keys = require "../model/data"

class UserService
  constructor: (@redis) ->

  fetchUserById: (uid) ->

  fetchUserByUserName: (username, callback) ->
    @redis.get keys.username_uid(username), (err, uid) ->
      if err?
        callback err
      else if uid?
        user = {
          uid: uid
          username: username
        }
        callback null, user
      else
        callback null, null

  createUser: (username, password, callback) ->
    @fetchUserByUserName username, (err, user) =>
      if user?
        callback new Error "User with username #{username} already exists"
      else
        # inc global next user Id
        @redis.incr keys.global.nextUserId, (err, nextUserId) =>

          @redis.multi()
            # set uid:nextUserId:username username
            .set(keys.uid_username(nextUserId), username)

            # set uid:nextUserId:password password
            .set(keys.uid_password(nextUserId), password)

            # set username:username:uid: nextUserId
            .set(keys.username_uid(username), nextUserId)

            .lpush(keys.uid, nextUserId)

            .exec (err, replies) =>
              callback err, user = {
                username: username
                uid: nextUserId
              }

  follow: (followingUsername, followedUsername, callback) ->

    @fetchUserByUserName followedUsername, (err, followedUser) =>
      if not followedUser?
        callback new Error "No user called #{followedUser?.username}"
      else
        @fetchUserByUserName followingUsername, (err, followingUser) =>
          if not followingUser?
            callback new Error "No user called #{followingUser.username}"
          else
            @redis.multi()
              # add followed user to following list
              .sadd(keys.uid_following(followingUser.uid), followedUser.uid)

              # add following user to the followers list
              .sadd(keys.uid_followers(followedUser.uid), followingUser.uid)

              .exec (err, replies) =>
                callback err

module.exports = UserService
