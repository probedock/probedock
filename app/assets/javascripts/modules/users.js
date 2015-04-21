angular.module('probe-dock.users', ['probe-dock.api', 'probe-dock.state'])

  .factory('UserService', ['$window', function($window) {

    var jvent = new $window.Jvent();

    return {
      on: _.bind(jvent.on, jvent),
      emit: _.bind(jvent.emit, jvent)
    };
  }])

  .controller('NewUserCtrl', ['ApiService', '$scope', 'UserService', function($api, $scope, $userService) {

    $scope.addNewUser = function() {
      if ($scope.newUserForm) {
        $scope.newUserForm.$setPristine();
      }

      $scope.newUser = {};
    };

    $scope.cancel = function() {
      delete $scope.newUser;
    };

    $scope.save = function() {
      $api.http({
        method: 'POST',
        url: '/api/users',
        data: $scope.newUser
      }).then(onSaved, onSaveError);
    };

    function onSaveError() {
      $scope.saveError = true;
    }

    function onSaved(response) {
      $userService.emit('created', response.data);
      delete $scope.newUser;
    }
  }])

  .controller('UsersListCtrl', ['ApiService', '$scope', 'StateService', 'UserService', function($api, $scope, $stateService, $userService) {

    var page = 1;
    // TODO: recursively fetch all users
    fetchUsers().then(addUsers);

    $stateService.onState({ name: [ 'users', 'users.details' ] }, $scope, function(state, params) {
      if (state.name == 'users.details') {
        $scope.selectedUserId = params.userId;
      } else {
        delete $scope.selectedUserId;
      }
    });

    $scope.timeFromNow = function(iso8601) {
      return new Date().getTime() - new Date(iso8601).getTime();
    };

    $userService.on('created', function(user) {
      $scope.users.unshift(user);
      $scope.lastCreatedUser = user;
    });

    $userService.on('updated', function(user) {
      var updatedUser = _.findWhere($scope.users, { id: user.id });
      if (updatedUser) {
        _.extend(updatedUser, user);
      }
    });

    $userService.on('deleted', function(user) {
      var deletedUser = _.findWhere($scope.users, { id: user.id });
      if (deletedUser) {
        $scope.users.splice(_.indexOf($scope.users, deletedUser), 1);
      }
    });

    function fetchUsers() {
      return $api.http({
        method: 'GET',
        url: '/api/users',
        params: {
          pageSize: 50,
          'sort[]': [ 'name asc' ]
        }
      });
    }

    function addUsers(response) {
      $scope.users = ($scope.users || []).concat(response.data);
    }
  }])

  .controller('UserDetailsCtrl', ['ApiService', 'AuthService', '$scope', '$state', 'StateService', 'UserService', '$window', function($api, $auth, $scope, $state, $stateService, $userService, $window) {

    var userId;
    reset();

    $stateService.onState({ name: [ 'users', 'users.details' ] }, $scope, function(state, params) {
      if (state.name == 'users.details' && params.userId != userId) {
        reset();
        userId = params.userId;
        fetchUser().then(showUser);
      } else {
        reset();
      }
    });

    $scope.delete = function() {
      if (!$window.confirm('Are you sure you want to delete user ' + $scope.selectedUser.name + '?')) {
        return;
      }

      $scope.deleteError = false;

      $api.http({
        method: 'DELETE',
        url: '/api/users/' + $scope.selectedUser.id
      }).then(onDeleted, onDeleteError);
    };

    $scope.toggleActive = function() {

      $scope.busy = true;
      var newActive = !$scope.selectedUser.active;

      $api.http({
        method: 'PATCH',
        url: '/api/users/' + $scope.selectedUser.id,
        data: {
          active: newActive
        }
      }).then(onActiveToggled);
    };

    $scope.edit = function() {
      $scope.editedUser = _.pick($scope.selectedUser, 'name', 'email');
    };

    $scope.cancelEdit = function() {
      delete $scope.editedUser;
      delete $scope.editError;
    };

    $scope.save = function() {

      $scope.busy = true;
      delete $scope.editError;

      $api.http({
        method: 'PATCH',
        url: '/api/users/' + $scope.selectedUser.id,
        data: $api.compact($scope.editedUser)
      }).then(onSaved, onEditError);
    };

    function onDeleted() {
      $userService.emit('deleted', { id: $scope.selectedUser.id });
      $state.go('users');
    }

    function onDeleteError() {
      $scope.deleteError = true;
    }

    function onSaved(response) {

      $scope.selectedUser = response.data;
      $userService.emit('updated', response.data);

      if ($auth.currentUser.id === response.data.id) {
        _.extend($auth.currentUser, response.data);
      }

      delete $scope.editedUser;
      $scope.busy = false;
    }

    function onEditError() {
      $scope.editError = true;
      $scope.busy = false;
    }

    function onActiveToggled(response) {
      $scope.selectedUser.active = response.data.active;
      $scope.busy = false;
    }

    function reset() {
      userId = null;
      delete $scope.selectedUser;
      delete $scope.editedUser;
      delete $scope.editError;
      delete $scope.deleteError;
      $scope.busy = false;
    }

    function fetchUser() {
      $scope.loadingSelectedUser = true;
      return $api.http({
        method: 'GET',
        url: '/api/users/' + userId
      });
    }

    function showUser(response) {
      $scope.selectedUser = response.data;
      $scope.loadingSelectedUser = false;
    }
  }])

;
