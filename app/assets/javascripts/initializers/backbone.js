// Copyright (c) 2012-2014 Lotaris SA
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
Backbone.fetchHalHref = function(refs, source, deferred) {

  var deferred = deferred || $.Deferred();

  var url;
  if (source) {

    if (!_.isObject(source._links)) {
      throw new Error('Expected source to have a links in the _links property, got ' + JSON.stringify(source));
    }

    var ref = refs.shift();

    var link = source._links[ref.rel];
    if (!link) {
      throw new Error('Expected source links to have a ' + ref.rel + ' link, got ' + _.keys(source._links).join(', '));
    } else if (!link.href) {
      throw new Error('Expected source link ' + ref.rel + ' to have an href property, got ' + JSON.stringify(link));
    } else if (ref.template && !link.templated) {
      throw new Error('Template parameters were given for link ' + ref.rel + ' but it is not templated, got ' + JSON.stringify(link));
    }

    url = link.href;
    if (ref.template) {
      url = new UriTemplate(url);
      url = url.fillFromObject(ref.template);
    }
  } else {
    url = ApiPath.build();
  }

  if (!refs.length) {
    App.debug('HAL link is ' + url);
    deferred.resolve(url);
    return deferred;
  }

  App.debug('Fetching HAL link ' + refs[0].rel + ' from ' + url);

  $.ajax({
    url: url,
    type: 'GET',
    dataType: 'json'
  }).done(function(response) {
    Backbone.fetchHalHref(refs, response, deferred);
  }).fail(function() {
    deferred.reject('Could not GET ' + url);
  });

  return deferred;
};

Backbone.originalSync = Backbone.sync;
Backbone.sync = function(method, model, options) {
  if (model.url) {
    return Backbone.originalSync.apply(Backbone, Array.prototype.slice.call(arguments));
  }

  var args = Array.prototype.slice.call(arguments),
      deferred = $.Deferred();

  Backbone.fetchHalHref(model.halUrl).fail(_.bind(deferred.reject, deferred)).done(function(url) {
    model.url = url;
    Backbone.originalSync.apply(Backbone, args).done(_.bind(deferred.resolve, deferred)).fail(_.bind(deferred.reject, deferred));
  });

  return deferred;
};
