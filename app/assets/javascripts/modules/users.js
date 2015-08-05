angular.module('probedock.users', [ 'probedock.api', 'probedock.state', 'probedock.utils' ])

  .factory('users', function(api, auth, eventUtils, $modal, $rootScope) {

    var service = eventUtils.service({

      openDetailsForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/user-details-modal.html',
          controller: 'UserDetailsFormCtrl',
          scope: $scope
        });

        $scope.$on('$stateChangeStart', function() {
          modal.dismiss('stateChange');
        });

        return modal;
      },

      getUser: function(id) {
        return api.getResource(id, '/users').then(function(res) {
          return res.data;
        });
      },

      updateUser: function(user) {
        return api.patchResource(user, '/users').then(function(updatedUser) {

          if (auth.currentUser && updatedUser.id == auth.currentUser.id) {
            auth.updateCurrentUser(updatedUser);
          }

          service.emit('update', updatedUser);

          return updatedUser;
        });
      },

      deleteUser: function(user) {
        return api.deleteResource(user, '/users');
      }
    });

    return service;
  })

  .controller('UserDetailsFormCtrl', function(forms, $modalInstance, $scope, users) {

    $scope.editedUser = angular.copy($scope.user);

    $scope.changed = function() {
      return !forms.dataEquals($scope.user, $scope.editedUser);
    };

    $scope.save = function() {
      users.updateUser($scope.editedUser).then($modalInstance.close);
    };
  })

  .controller('UserManagementCtrl', function($q, $scope, $state, $stateParams, states, tables, users) {

    $scope.userTabs = [];
    $scope.activeTabs = {};

    tables.create($scope, 'usersList', {
      url: '/users',
      pageSize: 15
    });

    users.forward($scope, 'update', { prefix: 'users.' });

    $scope.$on('users.update', function(event, user) {

      // update user if present in list
      var listUser = _.findWhere($scope.usersList.records, { id: user.id });
      if (listUser) {
        $scope.usersList.records[$scope.usersList.records.indexOf(listUser)] = user;
      }

      // update user in open tab
      var userTab = _.findWhere($scope.userTabs, { id: user.id });
      if (userTab) {
        userTab.user = user;
      }
    });

    states.onState($scope, 'admin.users', function() {
      selectTab('list');
    });

    states.onState($scope, /^admin.users.show\.?/, function(toState, toParams) {
      openUserTab(toParams.id);
    });

    $scope.delete = function(user) {
      if (!confirm('Are you sure you want to delete user "' + user.name + '"?')) {
        return;
      }

      users.deleteUser(user).then(function() {

        // remove user from list if present
        var listUser = _.findWhere($scope.usersList.records, { id: user.id });
        if (listUser) {
          $scope.usersList.records.splice($scope.usersList.records.indexOf(listUser), 1);
        }

        // close user tab if open
        var userTab = _.findWhere($scope.userTabs, { id: user.id });
        if (userTab) {
          $scope.removeTab(userTab);
        }
      });
    };

    $scope.removeTab = function(tab) {

      delete $scope.activeTabs[tab.id];
      $scope.userTabs.splice($scope.userTabs.indexOf(tab), 1);

      if ($stateParams.id == tab.id) {
        // FIXME: does not work
        $state.go('admin.users');
      }
    };

    $scope.timeFromNow = function(iso8601) {
      return new Date().getTime() - new Date(iso8601).getTime();
    };

    function openUserTab(userId) {

      var tab = _.findWhere($scope.userTabs, { id: userId });
      if (!tab) {
        tab = { id: userId };
        $scope.userTabs.push(tab);
      }

      selectTab(userId);

      if (!tab.user) {
        if (tab.loading) {
          return;
        }

        tab.loading = true;

        getTabUser($stateParams.id).then(function(user) {
          tab.loading = false;
          tab.user = user;
        });
      }
    }

    function getTabUser(id) {

      var user = _.findWhere($scope.usersList.records, { id: id });

      if (user) {
        return $q.when(user);
      } else {
        return users.getUser(id);
      }
    }

    function selectTab(id) {

      _.each($scope.activeTabs, function(value, key) {
        $scope.activeTabs[key] = false;
      });

      $scope.activeTabs[id] = true;
    }
  })

  .directive('userDetails', function() {
    return {
      restrict: 'E',
      scope: {
        user: '=',
        mode: '@'
      },
      templateUrl: '/templates/user-details.html',
      controller: function(auth, $scope, $state, $stateParams, states, users) {

        $scope.edit = function() {
          if ($scope.mode == 'profile') {
            $state.go('profile.edit');
          } else {
            $state.go('admin.users.show.edit', { id: $stateParams.id });
          }
        };

        states.onState($scope, /\.edit$/, function() {
          modal = users.openDetailsForm($scope);

          modal.result.then(function(user) {
            $state.go('^', {}, { inherit: true });
          }, function(reason) {
            if (reason != 'stateChange') {
              $state.go('^', {}, { inherit: true });
            }
          });
        });
      }
    };
  })

  .directive('userAvatar', function() {
    return {
      restrict: 'E',
      templateUrl: '/templates/user-avatar.html',
      controller: 'UserAvatarCtrl',
      scope: {
        user: '=',
        size: '=',
        nameTooltip: '='
      }
    };
  })

  .controller('UserAvatarCtrl', function($scope) {

    $scope.$watch('nameTooltip', function(value) {
      $scope.tooltipEnabled = !!value;
    });

    $scope.$watch('size', function(value) {
      if (value == 'large') {
        $scope.gravatarSize = 64;
      } else {
        $scope.gravatarSize = 30;
      }
    });
  })

  .directive('uniqueUserName', function(api, $q) {
    return {
      require: 'ngModel',
      link: function(scope, element, attrs, ctrl) {
        ctrl.$asyncValidators.uniqueUserName = function(modelValue) {

          // If the name is blank or is the same as the previous name,
          // then there can be no name conflict with another user.
          if (_.isBlank(modelValue) || (_.isPresent(scope.user.name) && modelValue == scope.user.name)) {
            return $q.when();
          }

          return api({
            url: '/users',
            params: {
              name: modelValue,
              pageSize: 1
            }
          }).then(function(res) {
            // value is invalid if a matching user is found (length is 1)
            return $q[res.data.length ? 'reject' : 'when']();
          }, function() {
            // consider value valid if uniqueness cannot be verified
            return $q.when();
          });
        };
      }
    };
  })

;
