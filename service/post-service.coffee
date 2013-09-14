keys = require "../model/data"

class PostService


  getNextPid: (gotPid) ->
    @redis.incr keys.global.nextPostId, gotPid


  savePost: (uid, message, saveCallback) ->
    @getNextPid (err, pid) =>
      if err?
        saveCallback err
      else
        time = (new Date()).getTime()
        @redis.set keys.post(pid), "#{uid}|#{time}|message", (err) ->
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




  constructor: (@redis) ->

  post: (username, message, callback) ->
    @redis.get keys.username_uid(username), (err, uid) =>
      if err? || not uid?
        callback err ? new Error "No user called #{username}"
      else
        @savePost uid, message, (err, pid) =>
          if err?
            callback err
          else
            @addToTimeLines uid, pid, (err) -> callback err, pid

  addMessageToUserTimeline: (uid, pid, callback) ->
    @redis.lpush keys.uid_posts(pid), pid, (err) ->
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