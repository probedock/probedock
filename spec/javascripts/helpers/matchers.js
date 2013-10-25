
beforeEach(function() {

  this.addMatchers({

    toLinkTo: function(href, contents, options) {

      var actual = this.actual,
          notText = this.isNot ? ' not' : '',
          typeMatches = false,
          nodeMatches = false,
          hrefMatches = false,
          contentsMatch = false,
          optionsMatch = false;

      var typeMatches = actual instanceof jQuery;
      if (typeMatches) {
        nodeMatches = actual.is('a');
        hrefMatches = actual.attr('href') == href;
        contentsMatch = !contents || actual.text() == contents;
        optionsMatch = !options;
      }

      this.message = function() {
        return "Expected " + actual + notText + " to be a link to " + href + " with contents " + contents + " and options " + JSON.stringify(options || {});
      };

      return typeMatches && nodeMatches && hrefMatches && contentsMatch && optionsMatch;
    },

    toHaveBackboneRelation: function(expected) {

      var actual = this.actual,
          relations = actual.prototype.relations;

      var relation = _.findWhere(relations, { key: expected.key }),
          notText = this.isNot ? ' not' : '';

      this.message = function() {
        return "Expected " + actual + notText + " to have a relation " + JSON.stringify(expected);
      };

      return relation && _.every(expected, function(value, key) {
        return relation[key] == value;
      });
    }
  });
});
