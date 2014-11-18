angular.module('rox.users', ['rox.api', 'rox.state'])

  .controller('UsersListCtrl', ['ApiService', '$scope', 'StateService', function($api, $scope, $stateService) {

    var page = 1;
    // TODO: recursively fetch all users
    fetchUsers().then(addUsers);

    $stateService.onState({ name: [ 'std.users', 'std.users.details' ] }, $scope, function(state, params) {
      if (state.name == 'std.users.details') {
        $scope.selectedUserId = params.userId;
      } else {
        delete $scope.selectedUserId;
      }
    });

    $scope.timeFromNow = function(iso8601) {
      return new Date().getTime() - new Date(iso8601).getTime();
    };

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

  .controller('UserDetailsCtrl', ['ApiService', '$scope', 'StateService', '$window', function($api, $scope, $stateService, $window) {

    var userId;
    reset();

    $stateService.onState({ name: [ 'std.users', 'std.users.details' ] }, $scope, function(state, params) {
      if (state.name == 'std.users.details' && params.userId != userId) {
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
      $scope.editedUser = angular.copy($scope.selectedUser);
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
        data: $scope.editedUser
      }).then(onSaved, onEditError);
    };

    function onDeleted() {
      reset();
    }

    function onDeleteError() {
      $scope.deleteError = true;
    }

    function onSaved(response) {
      $scope.selectedUser = response.data;
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
