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
App.watchStatus = function(source, func, options) {

  var only = options && options.only ? (_.isArray(options.only) ? options.only : [ options.only ]) : null,
      except = options && options.except ? (_.isArray(options.except) ? options.except : [ options.except ]) : [],
      context = options ? options.context : null;

  source.listenTo(App, 'status:changed', function(changed) {
    var actualOnly = only || _.keys(changed);
    if (!_.isEmpty(_.difference(_.intersection(_.keys(changed), actualOnly), except))) {
      func.call(context || source, changed);
    }
  });

  App.trigger('status:watch');
};
