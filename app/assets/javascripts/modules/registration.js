angular.module('probedock.registration', [ 'probedock.api', 'probedock.auth' ])

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

  .controller('ConfirmUserRegistrationCtrl', function(api, auth, $scope, $state, $stateParams) {

    $scope.confirmRegistration = confirmRegistration;

    api({
      url: '/registrations',
      params: {
        otp: $stateParams.otp
      }
    }).then(function(res) {
      if (!res.data.length) {
        $state.go('error', { type: 'notFound' });
      } else {
        $scope.registration = res.data[0];
      }
    });

    function confirmRegistration() {
      updateUser().then(signIn).then(goToOrg);
    }

    function updateUser() {

      var data = _.pick($scope.registration.user, 'password', 'passwordConfirmation');
      data.active = true;

      return api({
        method: 'PATCH',
        url: '/users/' + $scope.registration.user.id,
        data: data,
        params: {
          registrationOtp: $stateParams.otp
        }
      });
    };

    function signIn() {
      return auth.signIn({ username: $scope.registration.user.name, password: $scope.registration.user.password });
    }

    function goToOrg() {
      $state.go('org.dashboard.default', { orgName: $scope.registration.organization.name });
    }
  })

;
