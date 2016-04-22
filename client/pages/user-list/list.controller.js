angular.module('probedock.userListPage').controller('UserListPageCtrl', function($q, $scope, $state, states, tables, users) {

  $scope.states = [{
    active: 1,
    name: 'Active'
  },{
    active: 0,
    name: 'Inactive'
  }];

  $scope.types = [{
    technical: true,
    name: 'Technical'
  },{
    technical: false,
    name: 'Human'
  }];

  $scope.userTabs = [];
  $scope.tabset = {
    active: 0
  };

  tables.create($scope, 'usersList', {
    url: '/users',
    pageSize: 15,
    params: {
      withOrganizations: 1
    }
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
    });
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

    selectTab($scope.userTabs.indexOf(tab) + 1);

    if (!tab.user) {
      if (tab.loading) {
        return;
      }

      tab.loading = true;

      getTabUser(userId).then(function(user) {
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

  function selectTab(index) {
    $scope.tabset.active = index == 'list' ? 0 : index;
  }
});
