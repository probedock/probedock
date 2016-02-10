angular.module('probedock.reportDetailsPage').directive('reportHealthTooltips', function($compile, $document) {
  return function($scope, element, attrs) {

    var titleTemplate = _.template('<strong class="<%= titleClass %>"><%- title %></strong>'),
        contentTemplate = _.template('<ul class="list-unstyled"><li><strong>Duration:</strong> <%- duration %></li></ul>');

    element.on('click', 'a', function() {

      var e = $(this);

      var testElement;
      if (e.data('k')) {
        testElement = $('#test-k-' + e.data('k'));
      } else if (e.data('n')) {
        testElement = $('#test-n-' + e.data('n').replace(/\s+/g, '').replace(/[^A-Za-z0-9\_\-]/g, ''));
      }

      if (testElement.length) {
        $document.duScrollTo(testElement, 50, 1000);
      }
    });

    element.on('mouseenter', 'a', function() {

      var e = $(this);

      if (!e.data('bs.popover')) {

        var titleClass = 'text-success';

        if (e.is('.f')) {
          titleClass = 'text-danger';
        } else if (e.is('.i')) {
          titleClass = 'text-warning';
        }

        e.popover({
          trigger: 'hover manual',
          placement: 'auto',
          title: titleTemplate({ title: e.data('n'), titleClass: titleClass }),
          // FIXME: format duration
          content: contentTemplate({ duration: e.data('d') + 'ms' }),
          html: true
        });

        e.popover('show');
      }
    });
  };
});
