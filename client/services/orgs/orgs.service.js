angular.module('probedock.orgs').factory('orgs', function(api, appStore, auth, eventUtils, $rootScope, $state, states, $q) {

  var service = eventUtils.service({

    organizations: [],

    currentOrganization: appStore.get('currentOrganization'),
    currentOrganizationName: null,

    addOrganization: function(org) {
      service.organizations.push(org);
      service.emit('refresh', service.organizations);
    },

    getOrganization: function(orgId) {
      var org =_.findWhere(service.organizations, { id: orgId });

      if (_.isUndefined(org)) {
        return api({
          url: '/organizations/' + orgId
        }).then(function(response) {
          service.addOrganization(response.data);
          return response.data;
        });
      } else {
        return $q.when(org);
      }
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

    addAuthFunctions: function($scope) {

      $scope.currentMember = function() {
        return $rootScope.currentUserIs('admin') || auth.currentUser && service.currentOrganization && service.currentOrganization.member;
      };

      $scope.currentMemberIs = function() {
        if ($rootScope.currentUserIs('admin')) {
          return true;
        }

        var org = service.currentOrganization,
            roles = Array.prototype.slice.call(arguments);

        return org && _.isArray(org.roles) && _.intersection(org.roles, roles).length == roles.length;
      };

      auth.addAuthFunctions($scope);
    },

    refreshOrgs: function() {
      return api({
        url: '/organizations',
        params: {
          accessible: 1,
          withRoles: 1
        }
      }).then(function(res) {
        setOrganizations(res.data);
        return res.data;
      });
    }
  });

  service.refreshOrgs();
  $rootScope.$on('auth.signIn', service.refreshOrgs);
  $rootScope.$on('auth.signOut', forgetPrivateData);

  states.onState($rootScope, /^org\./, function(state, params, resolves) {
    var name = resolves.routeOrgName;
    service.currentOrganizationName = name;
    setCurrentOrganization(_.findWhere(service.organizations, { name: name }));
  });

  function forgetPrivateData() {
    if (service.currentOrganization && !service.currentOrganization.public) {
      setCurrentOrganization(null);
      $state.go('home');
    }

    setOrganizations(_.map(_.where(service.organizations, { public: true }), function(org) {
      return _.omit(org, 'roles');
    }));
  }

  function setCurrentOrganization(org) {
    service.currentOrganization = org;
    appStore.set('currentOrganization', org);
    service.emit('changedOrg', org);
  }

  function setOrganizations(orgs) {
    service.organizations = orgs;
    service.emit('refresh', orgs);

    if (service.currentOrganization) {
      setCurrentOrganization(_.findWhere(orgs, { id: service.currentOrganization.id }));
    } else if (service.currentOrganizationName) {
      setCurrentOrganization(_.findWhere(orgs, { name: service.currentOrganizationName }));
    }
  }

  return service;
});
