angular.module('probe-dock.help', [ 'probe-dock.api', 'probe-dock.orgs', 'probe-dock.utils' ])

  .controller('GettingStartedCtrl', function(api, orgs, $scope, $stateParams, yaml) {

    orgs.forwardData($scope);

    var apiUrl = window.location.protocol + '//' + window.location.hostname;
    if (window.location.port != '80' && window.location.port != '443') {
      apiUrl += ':' + window.location.port;
    }

    apiUrl += '/api';

    var serverName = window.location.hostname;

    $scope.homeConfiguration = {
      servers: {},
      publish: true
    };

    $scope.homeConfiguration.servers[serverName] = {
      apiUrl: apiUrl
    };

    $scope.homeYaml = '';
    $scope.homeScript = '';

    $scope.$watch('homeConfiguration', function(value) {
      if (value) {
        var yamlConfiguration = yaml.dump(value).trim();
        $scope.homeYaml = yamlConfiguration;
        $scope.homeScript = 'mkdir -p ~/.probe-dock && echo "' + yamlConfiguration.replace(/\n/g, "\\n") + '" > ~/.probe-dock/config.yml';
      }
    }, true);

    api({
      method: 'POST',
      url: '/tokens'
    }).then(function(res) {
      $scope.homeConfiguration.servers[serverName].apiToken = res.data.token;
    });

    $scope.projectConfiguration = {
      project: {
        apiId: 'PROJECT_ID_HERE',
        version: '1.0.0'
      },
      server: serverName
    };

    $scope.projectConfigSelection = {};

    $scope.$watch('organizations', function(value) {
      if (value) {
        $scope.projectConfigSelection.orgs = _.where(value, { member: true });
        if ($stateParams.organizationId && _.findWhere(value, { id: $stateParams.organizationId })) {
          $scope.projectConfigSelection.orgId = $stateParams.organizationId;
        }
      }
    });

    $scope.$watch('projectConfigSelection.projectId', function(value) {
      if (value) {
        $scope.projectConfiguration.project.apiId = value;
      }
    });

    $scope.$watch('projectConfigSelection.orgId', function(value) {
      if (value) {
        api({
          url: '/projects',
          params: {
            organizationId: value
          }
        }).then(function(res) {
          $scope.projectConfigSelection.projects = res.data;
          if ($stateParams.projectId && _.findWhere(res.data, { id: $stateParams.projectId })) {
            $scope.projectConfigSelection.projectId = $stateParams.projectId;
          }
        });
      }
    });

    $scope.projectYaml = '';
    $scope.projectScript = '';

    $scope.$watch('projectConfiguration.project.apiId', function(value) {
      if (value) {
        var yamlConfiguration = yaml.dump($scope.projectConfiguration).trim();
        $scope.projectYaml = yamlConfiguration;
        $scope.projectScript = 'echo "' + yamlConfiguration.replace(/\n/g, "\\n") + '" > probe-dock.yml';
      }
    }, true);
  })

;
