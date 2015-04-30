angular.module('probe-dock.keys', [ 'probe-dock.storage' ])

  .directive('testKeyGenerator', function() {
    return {
      restrict: 'E',
      controller: 'TestKeyGeneratorCtrl',
      templateUrl: '/templates/test-key-generator.html'
    };
  })

  .controller('TestKeyGeneratorCtrl', function(api, appStore, auth, orgs, projects, $q, $scope) {

    $scope.generator = _.defaults({}, appStore.get('org.' + orgs.currentOrganization.id + '.testKeyGenerator'), {
      number: 1,
      projectId: null
    });

    $scope.$watch('generator', function(value) {
      if (value.number && value.projectId) {
        appStore.set('org.' + orgs.currentOrganization.id + '.testKeyGenerator', _.pick(value, 'number', 'projectId'));
      }
    }, true);

    $scope.copiedKeysByProject = appStore.get('org.' + orgs.currentOrganization.id + '.testKeyGenerator.copied') || {};

    $scope.copy = function(key) {
      if (!$scope.copiedKeysByProject[key.projectId]) {
        $scope.copiedKeysByProject[key.projectId] = [];
      }

      $scope.copiedKeysByProject[key.projectId].push(key.key);
    };

    $scope.keyCopied = function(key) {
      return $scope.copiedKeysByProject[key.projectId] && $scope.copiedKeysByProject[key.projectId].indexOf(key.key) != -1;
    };

    $scope.$watch('copiedKeysByProject', function(value) {
      if (value !== undefined) {
        appStore.set('org.' + orgs.currentOrganization.id + '.testKeyGenerator.copied', $scope.copiedKeysByProject);
      }
    }, true);

    $scope.numberOfKeys = 0;
    $scope.keysByProject = {};

    projects.forwardProjects($scope);

    var fetchKeys = fetchKeys();

    var fetchProjects = projects.fetchProjects(orgs.currentOrganization.id).then(function(projects) {
      if (!_.findWhere(projects, { id: $scope.generator.projectId })) {
        $scope.generator.projectId = null;
      }

      if (!$scope.generator.projectId && projects.length) {
        $scope.generator.projectId = projects[0].id;
      }
    });

    $q.all([ fetchKeys, fetchProjects ]).then(cleanCopiedKeys);

    $scope.generate = function() {
      api({
        method: 'POST',
        url: '/test-keys',
        params: {
          n: $scope.generator.number
        },
        data: _.pick($scope.generator, 'projectId')
      }).then(function(res) {
        addKeys(res.data);
      });
    };

    $scope.release = function() {
      if (!confirm('Are you sure you want to release these test keys?')) {
        return;
      }

      api({
        method: 'DELETE',
        url: '/test-keys'
      }).then(function() {
        $scope.numberOfKeys = 0;
        $scope.keysByProject = {};
        $scope.copiedKeysByProject = {};
      });
    };

    $scope.projectsWithKeys = function() {
      return _.filter($scope.projects, function(project) {
        return $scope.keysByProject[project.id];
      });
    };

    function addKeys(keys) {
      _.each(keys, function(key) {
        if (!$scope.keysByProject[key.projectId]) {
          $scope.keysByProject[key.projectId] = [];
        }

        $scope.numberOfKeys++;
        $scope.keysByProject[key.projectId].push(key);
      });
    }

    function fetchKeys(page) {
      page = page || 1;

      return api({
        url: '/test-keys',
        params: {
          organizationId: orgs.currentOrganization.id,
          userId: auth.currentUser.id,
          free: 1,
          page: page,
          pageSize: 50
        }
      }).then(function(res) {

        addKeys(res.data);

        if (res.pagination().hasMorePages) {
          return fetchKeys(++page);
        } else {
          return $q.when($scope.keys);
        }
      });
    }

    function cleanCopiedKeys() {
      console.log($scope.copiedKeysByProject);
      $scope.copiedKeysByProject = _.reduce($scope.copiedKeysByProject, function(memo, keys, projectId) {
        if (_.findWhere($scope.projects, { id: projectId })) {
          memo[projectId] = _.filter(keys, function(key) {
            return _.some($scope.keysByProject[projectId], function(existingKey) {
              return existingKey.key == key;
            });
          });
        }

        return memo;
      }, {});
      console.log($scope.copiedKeysByProject);
    }
  })

  .directive('testKeyLabel', function() {
    return {
      restrict: 'E',
      scope: {
        key: '=',
        copied: '=',
        onCopied: '&'
      },
      template: '<div class="label test-key-label" ng-class="{\'label-primary\': !copied, \'label-info\': copied}" clip-copy="key.key || key" clip-click="onCopied({ key: key })" tooltip="Click to copy">{{ key.key || key }}</div>'
    };
  })

;
