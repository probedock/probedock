angular.module('probedock')

  .run(function(orgs, $rootScope) {

    $rootScope.currentMember = function() {
      return $rootScope.currentUserIs('admin') || orgs.currentOrganization && orgs.currentOrganization.member;
    };

    $rootScope.currentMemberIs = function() {
      if ($rootScope.currentUserIs('admin')) {
        return true;
      }

      var org = orgs.currentOrganization,
          roles = Array.prototype.slice.call(arguments);

      return org && _.isArray(org.roles) && _.intersection(org.roles, roles).length == roles.length;
    };
  })

;
