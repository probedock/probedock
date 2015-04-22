angular.module('probe-dock.orgs', [ 'probe-dock.api', 'probe-dock.auth', 'probe-dock.forms', 'probe-dock.storage', 'probe-dock.utils' ])

  .factory('orgs', function(api, appStore, auth, eventUtils, $modal, $rootScope, $stateParams) {

    var service = eventUtils.service({

      organizations: [],
      currentOrganization: appStore.get('currentOrganization'),

      addOrganization: function(org) {
        service.organizations.push(org);
        service.emit('refresh', service.organizations);
      },

      updateOrganization: function(org) {

        var previousOrg = _.findWhere(service.organizations, { id: org.id });
        service.organizations[service.organizations.indexOf(previousOrg)] = org;
        service.emit('refresh', service.organizations);

        if (service.currentOrganization && service.currentOrganization.id == org.id) {
          service.currentOrganization = org;
          service.emit('changedOrg', org);
        }
      },

      forwardData: function($scope) {

        setScopeOrgs();
        setScopeCurrentOrg();

        service.forward($scope, 'changedOrg', 'refresh', { prefix: 'org.' });
        $scope.$on('org.refresh', setScopeOrgs);
        $scope.$on('org.changedOrg', setScopeCurrentOrg);

        function setScopeOrgs() {
          $scope.organizations = service.organizations;
        }

        function setScopeCurrentOrg() {
          $scope.currentOrganization = service.currentOrganization;
        }
      },

      openForm: function($scope) {

        var modal = $modal.open({
          templateUrl: '/templates/org-form-modal.html',
          controller: 'OrgFormCtrl',
          scope: $scope
        });

        var deregister = $scope.$on('$stateChangeStart', function() {
          modal.dismiss('stateChange');
          deregister();
        });

        $scope.$on('$destroy', deregister);

        return modal;
      }
    });

    refreshOrgs();
    $rootScope.$on('auth.signIn', refreshOrgs);
    $rootScope.$on('auth.signOut', hidePrivateOrgs);

    $rootScope.$on('$stateChangeSuccess', function(event, toState) {
      if (toState.name.indexOf('org.') === 0) {
        setCurrentOrganization(_.findWhere(service.organizations, { name: $stateParams.orgName }));
      }
    });

    function refreshOrgs() {
      if (auth.currentUser) {
        api({
          url: '/api/organizations'
        }).then(function(res) {
          setOrganizations(res.data);
        });
      }
    }

    function hidePrivateOrgs() {
      setOrganizations(_.where(service.organizations, { public: true }));
    }

    function setCurrentOrganization(org) {
      service.currentOrganization = org;
      appStore.set('currentOrganization', org);
      service.emit('changedOrg', org);
    }

    function setOrganizations(orgs) {
      service.organizations = orgs;
      service.emit('refresh', orgs);
    }

    return service;
  })

  .controller('OrgFormCtrl', function(api, forms, $modalInstance, orgs, $scope, $stateParams) {

    $scope.organization = {};
    $scope.editedOrg = {};

    if ($stateParams.orgName) {
      api({
        url: '/api/organizations/' + $stateParams.orgName
      }).then(function(res) {
        $scope.organization = res.data;
        reset();
      });
    } else {
      reset();
    }

    $scope.reset = reset;
    $scope.changed = function() {
      return !forms.dataEquals($scope.organization, $scope.editedOrg);
    };

    $scope.save = function() {

      var method = 'POST',
          url = '/api/organizations';

      if ($scope.organization.id) {
        method = 'PATCH';
        url += '/' + $scope.organization.id;
      }

      api({
        method: method,
        url: url,
        data: $scope.editedOrg
      }).then(function(res) {
        orgs[$scope.organization.id ? 'updateOrganization' : 'addOrganization'](res.data);
        $modalInstance.close(res.data);
      });
    };

    function reset() {
      $scope.editedOrg = angular.copy($scope.organization);
    }
  })

;
