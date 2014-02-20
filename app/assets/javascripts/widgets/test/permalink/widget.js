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
(function() {

  App.addTestWidget('permalink', Marionette.ItemView, {

    ui: {
      permalinkField: 'form input',
      permalinkButton: 'form button'
    },

    events: {
      'click form input': 'selectPermalink'
    },

    serializeData: function() {
      return { permalink: this.model.get('_links').bookmark.href };
    },

    onRender: function() {
      Clipboard.setup(this.ui.permalinkButton, this.model.get('_links').bookmark.href);
    },

    selectPermalink: function(e) {
      e.preventDefault();
      this.ui.permalinkField.setSelection(0, this.ui.permalinkField.val().length);
    }
  });
})();
