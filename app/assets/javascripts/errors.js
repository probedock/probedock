// Copyright (c) 2012-2013 Lotaris SA
//
// This file is part of ROX Center.
//
// ROX Center is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ROX Center is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.

var Errors = {

  show : function(xhr, form, model) {

    if (xhr) {

      return _.reduce(Errors.fromXHR(xhr, model), function(memo, errors, attr) {
        return memo || Errors._showAttributeErrors(form, attr, errors);
      }, false, this);

    } else {

      form.find('.error').removeClass('error');
      Errors.hideTooltips(form);
      return true;
    }
  },

  /**
   * Converts a 400 Bad Request response containing Rails
   * model errors to a javascript object:
   *
   * {
   *   attr1: [ error1, error2 ],
   *   attr2: [ error3 ]
   * }
   *
   * Each error has the following format:
   *
   * {
   *   message: "can't be blank",
   *   fullMessage: "Name can't be blank"
   * }
   *
   * The full message can only be translated if the model name
   * is given as the second argument. The translation for an
   * attribute will be retrieved from Rails with the key
   * "activerecord.attributes.{modelName}.{attr}"
   */
  fromXHR : function(xhr, model) {
    
    if (xhr.status != 400 || !xhr.getResponseHeader('Content-Type').match(/application\/json/)) {
      return;
    }

    var json = $.parseJSON(xhr.responseText);
    return _.inject(json, function(memo, errors, attr) {
      memo[attr] = Errors._parseAttrErrors(attr, errors, model);
      return memo;
    }, {});
  },

  /**
   * Converts the errors object returned by fromXHR to a list:
   *
   * [
   *   {
   *     attr: "name",
   *     message: "can't be blank",
   *     fullMessage: "Name can't be blank"
   *   },
   *   {
   *     attr: "value",
   *     message: "must be a number",
   *     fullMessage: "Value must be a number"
   *   }
   * ]
   */
  asList : function(errors) {
    return _.inject(errors, function(memo, errors, attr) {
      return memo.concat(_.map(errors, function(error) {
        return _.tap(_.clone(error), function(copy) {
          copy.attr = attr;
        });
      }));
    }, []);
  },

  /**
   * Shows a bootstrap tooltip to the right of the specified
   * element, with the specified error message. The tooltip must
   * be manually triggered by default.
   *
   * Options can be given to override the defaults.
   */
  showTooltip : function(el, error, options) {
    el.tooltip('destroy');
    el.tooltip(_.extend({
      title: error,
      placement: 'right',
      trigger: 'manual'
    }, options || {}));
    el.tooltip('show');
  },

  /**
   * Hides the bootstrap tooltip attached to the specified element.
   */
  hideTooltip : function(el) {
    el.tooltip('destroy');
  },

  hideTooltips : function(el) {
    el.find(':input').tooltip('destroy');
  },

  _parseAttrErrors : function(attr, errors, model) {
    return _.map(errors, function(error) {

      var res = {
        message: error
      };

      if (model) {
        res.fullMessage = Errors._fullMessage(model, attr, error);
      }

      return res;
    });
  },

  _showAttributeErrors : function(form, attr, errors) {

    var error = _.first(errors);
    var el = form.find(':input.' + attr);
    if (!el) {
      return false;
    }

    el.parents('.control-group').first().addClass('error');
    Errors.showTooltip(el, error.fullMessage, { placement : form.hasClass('form-inline') ? 'bottom' : 'right' });
    return true;
  },

  _fullMessage : function(model, attr, error) {
    return I18n.t('activerecord.attributes.' + model + '.' + attr) + ' ' + error;
  }
};
