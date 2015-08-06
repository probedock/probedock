angular.module('probedock.registration', [ 'probedock.api' ])

  .controller('UserRegistrationCtrl', function(api, $scope) {

    $scope.user = {};
    $scope.organization = {};

    $scope.register = function() {

      var data = {
        user: $scope.user,
        organization: $scope.organization
      };

      if (_.isBlank(data.organization.name) && _.isPresent($scope.organizationNamePlaceholder)) {
        data.organization.name = $scope.organizationNamePlaceholder;
      }

      api({
        method: 'POST',
        url: '/registrations',
        data: data
      }).then(function(res) {
        $scope.registration = res.data;
      });
    };

    $scope.$watch('organization.displayName', function(value) {
      value = value || '';

      $scope.organizationNamePlaceholder = value
        .replace(/[^a-z0-9\- ]+/gi, '')
        .replace(/ +/g, '-')
        .replace(/\-+/g, '-')
        .replace(/\-+$/, '')
        .replace(/^\-+/, '')
        .toLowerCase();
    });

    $scope.$watch('organizationNamePlaceholder', function(value) {
      if (_.isPresent($scope.organizationNamePlaceholder) && _.isBlank($scope.organization.name)) {
        checkOrganizationNamePlaceholderDebounced();
      } else {
        $scope.organizationNamePlaceholderTaken = false;
      }
    });

    var checkOrganizationNamePlaceholderDebounced = _.debounce(checkOrganizationNamePlaceholder, 500);

    function checkOrganizationNamePlaceholder() {
      $scope.organizationNamePlaceholderTaken = false;

      if (_.isBlank($scope.organizationNamePlaceholder)) {
        return;
      }

      api({
        url: '/organizations',
        params: {
          name: $scope.organizationNamePlaceholder,
          pageSize: 1
        }
      }).then(function(res) {
        $scope.organizationNamePlaceholderTaken = !!res.data.length;
      });
    }
  })

;
