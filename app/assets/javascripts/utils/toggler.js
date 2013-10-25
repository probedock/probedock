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

$(function() {

  $('[data-toggle]').click(function(e) {
    e.preventDefault();

    var el = $($(this).data('toggle'));
    if (el.data('busy')) {
      return;
    }

    if (el.data('toggle-data')) {

      var text = el.text();
      el.text(el.data('toggle-data'));
      el.data('toggle-data', text);

    } else if (el.data('toggle-remote')) {

      var url = el.data('toggle-remote');
      el.data('busy', true);
      $.ajax({
        url: url
      }).done(function(response) {
        el.data('busy', false);
        el.data('toggle-data', el.text());
        el.text(response);
      });
    }
  });
});
