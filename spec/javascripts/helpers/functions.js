
var cssFontSize = function(el, omitUnit) {
  var fontSize = el.css('font-size');
  return fontSize ? (omitUnit ? parseFloat(fontSize.replace(/[a-z]+$/, '')) : fontSize) : fontSize;
};

var fakeAjaxResponse = function(op, response, options) {

  var reqDone = false;
  response = _.extend(options || {}, { responseText: response });

  runs(function() {
    jasmine.Ajax.useMock();

    var xhr = op();
    expect(xhr).toBeTruthy();
    xhr.done(function() { reqDone = true; });

    mostRecentAjaxRequest().response(response);
  });

  waitsFor(function() {
    return reqDone;
  }, "the request to finish", 250);
};

var cleanRelational = function(models) {
  _.each(_.isArray(models) ? models : [ models ], function(model) {
    Backbone.Relational.store.unregister(model);
  });
};
