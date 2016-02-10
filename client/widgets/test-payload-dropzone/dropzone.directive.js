/**
 * Widget to manually upload a test results payload for a project in the UI. For example,
 * a user may generate a standard xUnit XML test report and drag-and-drop it into
 * the widget. This functionality is provided by the Dropzone library: http://www.dropzonejs.com/
 *
 * This widget is specific to one project, but it allows the user to choose the
 * project version and test category that will be used to process the payload.
 * Existing versions and categories can be selected, or the user can create new
 * ones.
 */
angular.module('probedock.testPayloadDropzoneWidget').directive('testPayloadDropzoneWidget', function() {
  return {
    restrict: 'E',
    controller: 'TestPayloadDropzoneWidgetCtrl',
    templateUrl: '/templates/widgets/test-payload-dropzone/dropzone.template.html',
    scope: {
      organization: '=',
      project: '='
    },
    link: function($scope, element) {

      // create the dropzone element
      $scope.dropzone = new Dropzone(element.find('.dropzone').get(0), {
        url: '/api/publish',
        // restrict to 1 file, as the drop zone will be cleared after each upload
        maxFiles: 1,
        // set the multipart/form-data parameter name that the file will be uploaded as
        paramName: 'payload',
        // accept the following mime types (this check is performed locally before attempting to upload)
        acceptedFiles: 'application/xml,application/json,text/xml,text/json'
      });

      /*
       * Broadcast dropzone's processing event to the scope.
       * This event is triggered when a file is dropped into the
       * drop zone, before the upload starts.
       */
      $scope.dropzone.on('processing', function() {
        $scope.$apply(function() {
          $scope.$broadcast('dropzone.processing');
          // update dropzone's headers with the widget's selected
          // configuration before the upload starts
          $scope.dropzone.options.headers = $scope.uploadHeaders;
        });
      });

      /*
       * Broadcast dropzone's error event to the scope.
       * This event is triggered when a local error occurs (e.g. invalid file)
       * or the server responds with an unexpected status code (e.g. payload invalid).
       */
      $scope.dropzone.on('error', function(event, msg, xhr) {
        $scope.$apply(function() {
          // clear all files in the drop zone
          $scope.dropzone.removeAllFiles();
          $scope.$broadcast('dropzone.error', msg, xhr);
        });
      });

      /*
       * Broadcast dropzone's success event to the scope.
       * This event is triggered after a file has been successfully uploaded.
       */
      $scope.dropzone.on('success', function(event, xhr) {
        $scope.$apply(function() {
          // clear all files in the drop zone
          $scope.dropzone.removeAllFiles();
          $scope.$broadcast('dropzone.success', xhr);
        });
      });
    }
  };
}).controller('TestPayloadDropzoneWidgetCtrl', function(api, errors, $scope) {

  // UI configuration
  $scope.formConfig = {
    // if false, display a dropdown menu to select an existing category,
    // otherwise, display a free input field to create a new one
    newCategory: false,
    // whether to show the drop zone
    uploadEnabled: true
  };

  // test payload configuration (i.e. version & category)
  $scope.uploadParams = {};

  // headers that will be sent with uploaded files
  $scope.uploadHeaders = api.authHeaders();

  // update the widget state and upload headers when the configuration changes
  $scope.$watch('uploadParams', function(params) {

    // only show the drop zone if a project version is present
    $scope.formConfig.uploadEnabled = params && params.projectVersion;

    if (!params) {
      return;
    }

    if (params.projectVersion) {
      $scope.uploadHeaders['Probe-Dock-Project-Version'] = params.projectVersion.name;
    } else {
      delete $scope.uploadHeaders['Probe-Dock-Project-Version'];
    }

    if (params.category) {
      $scope.uploadHeaders['Probe-Dock-Category'] = params.category;
    } else {
      delete $scope.uploadHeaders['Probe-Dock-Category'];
    }
  }, true);

  // hide all messages when an upload starts
  $scope.$on('dropzone.processing', function() {
    delete $scope.success;
    delete $scope.error;
    delete $scope.errorDetails;
  });

  // display a success message if an upload succeeds
  $scope.$on('dropzone.success', function() {
    $scope.success = true;
  });

  // display an error message if an upload fails
  $scope.$on('dropzone.error', function(event, msg, xhr) {
    $scope.error = msg;
    $scope.serverError = xhr;
  });

  // shows the details of an unexpected server response (modal dialog)
  $scope.showErrorDetails = function() {
    errors.showXhrErrors($scope, $scope.serverError);
  };

  // set up the widget only when the required directive parameters are present
  $scope.$watchGroup([ 'project', 'organization' ], function(values) {
    if (values[0] && values[1]) {
      setUpHeaders();
      fetchCategories();
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

      // if there is no existing category, automatically switch
      // to the free input field to create a new one
      $scope.formConfig.newCategory = !res.data.length;
    });
  }
});
