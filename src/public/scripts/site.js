var FollowController, GlobalTimelineController, LastRegisteredController, LoginController, TimelineController, UserPostsController;

LoginController = function($scope) {
  $scope.mode = 'in';
  $scope.action = 'login';
  $scope.mode_link = 'up';
  $scope.toggleMode = function() {
    $scope.mode = $scope.mode === 'up' ? 'in' : 'up';
    $scope.mode_link = $scope.mode === 'up' ? 'in' : 'up';
    $scope.action = $scope.mode === 'up' ? 'signup' : 'login';
  };
};

TimelineController = function($scope, $http) {
  $http.get("/api/" + $scope.username + "/timeline").success(function(posts) {
    return $scope.posts = posts;
  });
  return $scope.showUser = function(username) {
    return window.location.replace("/user/" + username);
  };
};

GlobalTimelineController = function($scope, $http) {
  $http.get('/api/globalTimeline').success(function(posts) {
    return $scope.posts = posts;
  });
  return $scope.showUser = function(username) {
    return window.location.replace("/user/" + username);
  };
};

UserPostsController = function($scope, $http) {
  var isFollowing;
  isFollowing = '';
  $scope.followButtonText = '?';
  $scope.followButtonClass = 'btn-xs';
  $scope.followButtonDisabled = true;
  $scope.$watch('username', function() {
    $scope.isSelfObserving = $scope.username === $scope.loggedInUser;
    if (!$scope.isSelfObserving) {
      $http.post('/api/isFollowing', {
        followingUser: $scope.loggedInUser,
        followedUser: $scope.username
      }).success(function(reply) {
        console.log(reply);
        $scope.followButtonDisabled = false;
        isFollowing = (reply != null ? reply.isFollowing : void 0) === 1;
        if (isFollowing) {
          $scope.followButtonText = 'Unfollow';
          return $scope.followButtonClass = 'btn btn-danger btn-xs';
        } else {
          $scope.followButtonText = 'Follow';
          return $scope.followButtonClass = 'btn btn-primary btn-xs';
        }
      });
    }
    return $http.get("/api/" + $scope.username + "/posts").success(function(posts) {
      return $scope.posts = posts;
    });
  });
  $scope.followAction = function() {
    if (isFollowing) {
      return $http["delete"]("/api/" + $scope.loggedInUser + "/follows/" + $scope.username).success(function(reply) {
        isFollowing = false;
        $scope.followButtonText = 'Follow';
        return $scope.followButtonClass = 'btn btn-primary btn-xs';
      });
    } else {
      return $http.post("/api/" + $scope.loggedInUser + "/follows/" + $scope.username).success(function(reply) {
        isFollowing = true;
        $scope.followButtonText = 'Unfollow';
        return $scope.followButtonClass = 'btn btn-danger btn-xs';
      });
    }
  };
  return $scope.showUser = function(username) {
    return window.location.replace("/user/" + username);
  };
};

FollowController = function($scope, $http) {
  $http.get("/api/" + $scope.username + "/follows").success(function(following) {
    return $scope.followings = following;
  });
  return $http.get("/api/" + $scope.username + "/followedBy").success(function(followers) {
    return $scope.followers = followers;
  });
};

LastRegisteredController = function($scope, $http) {
  $http.get("/api/lastRegistredUsers").success(function(users) {
    return $scope.users = users;
  });
  return $scope.showUser = function(username) {
    return window.location.replace("/user/" + username);
  };
};

/*
//@ sourceMappingURL=site.js.map
*/