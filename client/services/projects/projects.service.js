angular.module('probedock.projects').factory('projects', function(api, eventUtils, $q) {

  var currentOrg = null;

  var service = eventUtils.service({

    projects: [],

    forwardProjects: function($scope) {

      setScopeProjects();

      service.forward($scope, 'refresh', { prefix: 'projects.' });
      $scope.$on('projects.refresh', setScopeProjects);

      function setScopeProjects() {
        $scope.projects = service.projects;
      }
    },

    fetchProjects: function(orgId) {
      if (orgId != currentOrg) {
        currentOrg = orgId;
        service.projects = [];
        return fetchProjectsRecursive();
      } else {
        return $q.when(service.projects);
      }

      function fetchProjectsRecursive(page) {
        page = page || 1;

        return api({
          url: '/projects',
          params: {
            organizationId: orgId,
            page: page,
            pageSize: 25
          }
        }).then(function(res) {

          service.projects = service.projects.concat(res.data);

          if (res.pagination().hasMorePages) {
            return fetchProjectsRecursive(++page);
          } else {
            service.emit('refresh', service.projects);
            return service.projects;
          }
        });
      }
    }
  });

  return service;
});
