keys = require "../model/keys"

class PostService

  constructor: (@redis) ->

  getNextPid: (gotPid) ->
    @redis.incr keys.global.nextPostId, gotPid


  savePost: (username, message, saveCallback) ->
    @getNextPid (err, pid) =>
      if err?
        saveCallback err
      else
        time = (new Date()).getTime()
        @redis.set keys.post(pid), "#{username}|#{time}|#{message}", (err) ->
          saveCallback err, pid

  addToTimeLines: (uid, pid, timelineCallback) =>
    progress =
      global: false
      author: false
      followers: false
      aborted: false
      isDone: -> @followers && @author && @global

    genericCallback = (flag) =>
      (err) =>
        if err?
          if not progress.aborted
            progress.aborted = true
            timelineCallback err
        else
          progress[flag] = true
          if progress.isDone()
            timelineCallback()

    @addMessageToGlobalTimeline pid, genericCallback('global')

    @addMessageToUserTimeline uid, pid, genericCallback('author')

    @addMessageToUserFollowersTimeLine uid, pid, genericCallback('followers')

  fetchGlobalTimeline: (callback) ->
    @redis.lrange keys.global.timeline, 0, 199, (err, pids) =>
      if err?
        callback err
      else
        @fetchPostsForPids pids, callback

  fetchUserTimeline: (username, callback) ->
    @redis.get keys.username_uid(username), (err, uid) =>
      if err?
        callback err
      else
        @redis.lrange keys.uid_posts(uid), 0, 200, (err, pids) =>
          if err?
            callback err
          else
            @fetchPostsForPids pids, (err, posts) ->
              callback err, posts

  fetchPostsForPids: (pids, callback) ->
    multi = @redis.multi()
    for pid in pids
      multi = multi.get(keys.post(pid))
    multi.exec (err, replies) ->
      if err?
        callback err
      else
        posts = for post in replies
          parts = post.split '|'
          {user: parts[0], date: parts[1], message: parts[2]}
        callback err, posts


  post: (username, message, callback) ->
    @redis.get keys.username_uid(username), (err, uid) =>
      if err? || not uid?
        callback err ? new Error "No user called #{username}"
      else
        @savePost username, message, (err, pid) =>
          if err?
            callback err
          else
            @addToTimeLines uid, pid, (err) -> callback err, pid

  addMessageToUserTimeline: (uid, pid, callback) ->
    @redis.lpush keys.uid_posts(uid), pid, (err) ->
      if err?
        callback err
      else
        callback()

  addMessageToGlobalTimeline: (pid, callback) ->
    @redis.lpush keys.global.timeline, pid, (err) ->
      if err?
        callback err
      else
        callback()

    # trim
    @redis.ltrim keys.global.timeline, 0, 199

  addMessageToUserFollowersTimeLine: (uid, pid, callback) ->
    @redis.smembers keys.uid_followers(uid), (err, followers) =>
      if followers.length == 0 || err?
        callback err
      else
        followersCount = followers.length
        for follower in followers
          followersCount--
          @addMessageToUserTimeline follower, pid, (err) ->
            if followersCount == 0
              callback()

module.exports = PostService