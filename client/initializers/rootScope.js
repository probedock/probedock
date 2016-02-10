angular.module('probedock')

  .run(function(orgs, $rootScope) {
    orgs.addAuthFunctions($rootScope);
  })

;
