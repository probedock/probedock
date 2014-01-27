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
App.storage = {

  set: function(key, value, options) {
    $.jStorage.set(key, value, App.storage.jStorageOptions(options));
  },

  get: function(key, defaultValue) {
    return $.jStorage.get(key, defaultValue);
  },

  currentUser: {

    set: function(key, value, options) {
      return App.storage.set(App.storage.currentUser.cacheKey() + '.' + key, value, options);
    },

    get: function(key, defaultValue) {
      return App.storage.get(App.storage.currentUser.cacheKey() + '.' + key, defaultValue);
    },

    cacheKey: function() {
      if (!App.session) {
        throw new Error("App.session is required for current user storage.");
      } else if (!App.session.cache) {
        throw new Error("App.session.cache key is required for current user storage.");
      }

      return App.session.cache;
    }
  },

  size: function() {
    return $.jStorage.storageSize();
  },

  jStorageOptions: function(options) {
    options = options || {};
    return { TTL: options.ttl };
  }
};
