LoginController = ($scope) ->
  $scope.mode = 'in'
  $scope.action = 'login'
  $scope.mode_link = 'up'

  $scope.toggleMode = ->
    $scope.mode = if $scope.mode is 'up' then 'in' else 'up'
    $scope.mode_link = if $scope.mode is 'up' then 'in' else 'up'
    $scope.action = if $scope.mode is 'up' then 'signup' else 'login'
    return
  return


TimelineController = ($scope, $http) ->
  $http.get("/api/#{$scope.username}/timeline").success (posts) ->
    $scope.posts = posts

  $scope.showUser = (username) ->
    window.location.replace "/user/#{username}"

GlobalTimelineController = ($scope, $http) ->
  $http.get('/api/globalTimeline').success (posts) ->
    $scope.posts = posts

  $scope.showUser = (username) ->
    window.location.replace "/user/#{username}"

UserPostsController = ($scope, $http) ->

  isFollowing = ''

  $scope.followButtonText = '?'
  $scope.followButtonClass = 'btn-xs'
  $scope.followButtonDisabled = true

  $scope.$watch 'username', ->
    $scope.isSelfObserving = $scope.username is $scope.loggedInUser

    if not $scope.isSelfObserving
      $http.post('/api/isFollowing',
          {followingUser: $scope.loggedInUser, followedUser: $scope.username}).success (reply) ->
        console.log reply
        $scope.followButtonDisabled = false
        isFollowing = reply?.isFollowing is 1
        if isFollowing
          $scope.followButtonText = 'Unfollow'
          $scope.followButtonClass = 'btn btn-danger btn-xs'
        else
          $scope.followButtonText = 'Follow'
          $scope.followButtonClass = 'btn btn-primary btn-xs'


    $http.get("/api/#{$scope.username}/posts").success (posts) ->
      $scope.posts = posts

  $scope.followAction = ->
    if isFollowing
      $http.delete("/api/#{$scope.loggedInUser}/follows/#{$scope.username}").success (reply) ->
        isFollowing = false
        $scope.followButtonText = 'Follow'
        $scope.followButtonClass = 'btn btn-primary btn-xs'
    else
      $http.post("/api/#{$scope.loggedInUser}/follows/#{$scope.username}").success (reply) ->
        isFollowing = true
        $scope.followButtonText = 'Unfollow'
        $scope.followButtonClass = 'btn btn-danger btn-xs'

  $scope.showUser = (username) ->
    window.location.replace "/user/#{username}"

FollowController = ($scope, $http) ->
  $http.get("/api/#{$scope.username}/follows").success (following) ->
    $scope.followings = following

  $http.get("/api/#{$scope.username}/followedBy").success (followers) ->
    $scope.followers = followers

LastRegisteredController = ($scope, $http) ->
  $http.get("/api/lastRegistredUsers").success (users) ->
    $scope.users = users

  $scope.showUser = (username) ->
    window.location.replace "/user/#{username}"