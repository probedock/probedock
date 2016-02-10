angular.module('probedock.permalinksPage').controller('PermalinksPageCtrl', function(api, $q, $location, $state, $stateParams) {

  var params = $location.search();

  if ($stateParams.target == 'report') {
    findAndGoToReport();
  } else {
    notFound();
  }

  function findAndGoToReport() {

    var promise = $q.when();

    if (params.id) {
      promise = fetchReport(params.id);
    } else if (params.uid && params.organizationId) {
      promise = findReport(_.extend({
        withOrganization: 1
      }, _.pick(params, 'uid', 'organizationId')));
    } else if (params.payloadId && params.organizationId) {
      promise = findReport(_.extend({
        withOrganization: 1
      }, _.pick(params, 'payloadId', 'organizationId')));
    }

    promise.then(function(report) {
      if (!report) {
        return notFound();
      }

      goToReport(report);
    });
  }

  function findReport(params) {
    return api({
      url: '/reports',
      params: params
    }).then(function(res) {
      return res.data.length ? res.data[0] : null;
    });
  }

  function fetchReport(id) {
    return api({
      url: '/reports/' + id,
      params: {
        withOrganization: 1
      }
    }).then(function(res) {
      return res.data;
    });
  }

  function goToReport(report) {
    if (!report.organization) {
      return notFound();
    }

    $state.go('org.reports.show', { orgName: report.organization.name, id: report.id }, { location: 'replace' });
  }

  function notFound() {
    $state.go('error', { type: 'notFound' });
  }
});
