keys = require "../model/keys"
crypto = require 'crypto'

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
          nextUserId = '' + nextUserId
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

  fetchUsersByUids: (uids, callback) ->
    multi = @redis.multi()
    for uid in uids
      multi = multi.get(keys.uid_username(uid))
    multi.exec (err, replies) ->
      callback err, replies

  fetchFollowers: (username, callback) ->
    @redis.get keys.username_uid(username), (err, uid) =>
      @redis.smembers keys.uid_followers(uid), (err, followers) =>
        @fetchUsersByUids followers, (err, usernames) ->
          callback err, usernames

  fetchFollowings: (username, callback) ->
    @redis.get keys.username_uid(username), (err, uid) =>
      @redis.smembers keys.uid_following(uid), (err, followings) =>
        @fetchUsersByUids followings, (err, usernames) ->
          callback err, usernames

  lastRegistered: (callback) ->
    @redis.lrange keys.uid, 0, 20, (err, uids) =>
      @fetchUsersByUids uids, (err, usernames) ->
        callback err, usernames

  login: (username, password, callback) ->
    @fetchUserByUserName username, (err, user) =>
      if err? or not user?
        callback(err ? new Error "No user called #{username}")
      else
        @redis.get keys.uid_password(user.uid), (err, reply) =>
          if err?
            callback err
          else
            user.password = reply
            if user.password is password
              callback()
            else
              callback new Error "Username password mismatch"

  isFollowing: (followingUser, followedUser, callback) ->
    @redis.get keys.username_uid(followingUser), (err, uid) =>
      @redis.get keys.username_uid(followedUser), (err, fud) =>
        @redis.sismember keys.uid_following(uid), fud, (err, reply)  ->
          callback err, reply

module.exports = UserService
