angular.module('probedock.project', [ 'probedock.api', 'probedock.forms', 'probedock.utils' ])

  .controller('ProjectCtrl', function(api, forms, orgs, projects, $scope, $state, $stateParams) {

    orgs.forwardData($scope);

    api({
      url: '/projects',
      params: {
        organizationName: $stateParams.orgName,
        name: $stateParams.projectName
      }
    }).then(showProject);

    function showProject(response) {
	    if (response.data[0]) {
		    $scope.project = response.data[0];
	      console.log(response.data[0]);
	    }
    }
  })

;
