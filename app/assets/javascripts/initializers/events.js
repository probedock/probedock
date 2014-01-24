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
$.fn.extend({

  voidHandler: function(e) {
    if (typeof(e.preventDefault) == 'function') {
      e.preventDefault();
    }
    return false;
  }
});

App.bindEvents = function(target) {
  if (!target.appEvents) {
    throw new Error('Target must have an appEvents property.');
  }
  Marionette.bindEntityEvents(target, App, target.appEvents);
};
