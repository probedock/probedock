angular.module('probedock.project', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('ProjectCtrl', function (api, forms, orgs, projects, $scope, $state, $stateParams) {
    orgs.forwardData($scope);

    api({
      url: '/projects',
      params: {
        organizationName: $stateParams.orgName,
        name: $stateParams.projectName
      }
    })
    .then(function (response) {
      if (response.data[0]) {
        project = response.data[0];

        return api({
          url: '/reports',
          params: {
            projectId: project.id
          }
        })
        .then(function (response) {
          $scope.project = _.extend(project, {
            reportsCount: response.pagination().filteredTotal
          });
        });
      }
    });
  })

  .directive('projectRecentActivity', function() {
    return {
      restrict: 'E',
      controller: 'ProjectRecentActivityCtrl',
      controllerAs: 'ctrl',
      templateUrl: '/templates/project-recent-activity.html',
      scope: {
        organization: '=',
        project: '='
      }
    };
  })

  .controller('ProjectRecentActivityCtrl', function(api, $scope) {

    $scope.$watch('project', function(value) {
      if (value) {
        fetchReports();
      }
    });

    function fetchReports() {
      return api({
        url: '/reports',
        params: {
          pageSize: 5,
          projectId: $scope.project.id,
          withRunners: 1,
          withProjects: 1,
          withProjectVersions: 1,
          withCategories: 1,
          withProjectCountsFor: $scope.project.id
        }
      }).then(showReports);
    }

    function showReports(response) {
      $scope.reports = response.data;
    }
  })

  .directive('projectTestPayloadDropzone', function() {
    return {
      restrict: 'E',
      controller: 'ProjectTestPayloadDropzone',
      templateUrl: '/templates/project-test-payload-dropzone.html',
      scope: {
        organization: '=',
        project: '='
      },
      link: function($scope, element) {
        $scope.dropzone = new Dropzone(element.find('.dropzone').get(0), {
          url: '/api/publish',
          maxFiles: 1,
          paramName: 'payload',
          acceptedFiles: 'application/xml,application/json,text/xml,text/json'
        });

        $scope.dropzone.on('processing', function() {
          $scope.$apply(function() {
            $scope.$broadcast('dropzone.processing');
            $scope.dropzone.options.headers = $scope.uploadHeaders;
          });
        });

        $scope.dropzone.on('error', function(event, msg, xhr) {
          $scope.$apply(function() {
            $scope.dropzone.removeAllFiles();
            $scope.$broadcast('dropzone.error', msg, xhr);
          });
        });

        $scope.dropzone.on('success', function(event, xhr) {
          $scope.$apply(function() {
            $scope.dropzone.removeAllFiles();
            $scope.$broadcast('dropzone.success', xhr);
          });
        });
      }
    };
  })

  .controller('ProjectTestPayloadDropzone', function(api, errors, $scope) {

    $scope.formConfig = {
      newVersion: false,
      newCategory: false,
      uploadEnabled: true
    };

    $scope.uploadParams = {};
    $scope.uploadHeaders = api.authHeaders();

    $scope.$watch('uploadParams', function(params) {
      if (!params) {
        return;
      }

      if (params.projectVersion) {
        $scope.uploadHeaders['Probe-Dock-Project-Version'] = params.projectVersion;
      } else {
        delete $scope.uploadHeaders['Probe-Dock-Project-Version'];
      }

      if (params.category) {
        $scope.uploadHeaders['Probe-Dock-Category'] = params.category;
      } else {
        delete $scope.uploadHeaders['Probe-Dock-Category'];
      }
    }, true);

    $scope.$watch('uploadParams', function(params) {
      $scope.formConfig.uploadEnabled = params && !!params.projectVersion;
    }, true);

    $scope.$on('dropzone.processing', function() {
      delete $scope.success;
      delete $scope.error;
      delete $scope.errorDetails;
    });

    $scope.$on('dropzone.success', function() {
      $scope.success = true;
    });

    $scope.$on('dropzone.error', function(event, msg, xhr) {
      $scope.error = msg;
      $scope.serverError = xhr;
    });

    $scope.showErrorDetails = function() {
      errors.showXhrErrors($scope, $scope.serverError);
    };

    $scope.$watchGroup([ 'project', 'organization' ], function(values) {
      if (values[0] && values[1]) {
        setUpHeaders();
        fetchCategories();
        fetchVersions();
      }
    });

    function setUpHeaders() {
      _.extend($scope.uploadHeaders, {
        'Probe-Dock-Project-Id': $scope.project.id
      });
    }

    function fetchCategories() {
      api({
        url: '/categories',
        params: {
          organizationId: $scope.organization.id
        }
      }).then(function(res) {
        $scope.categories = res.data;
      });
    }

    function fetchVersions() {
      api({
        url: '/projectVersions',
        params: {
          projectId: $scope.project.id
        }
      }).then(function(res) {
        $scope.projectVersions = res.data;

        if (res.data.length) {
          $scope.uploadParams.projectVersion = res.data[0].name;
        } else {
          $scope.formConfig.newVersion = true;
          $scope.uploadParams.projectVersion = '1.0.0';
        }
      });
    }
  })

;
