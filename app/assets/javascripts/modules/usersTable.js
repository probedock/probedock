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

App.autoModule('usersTable', function() {

  var models = App.module('models'),
      User = models.User,
      UserTableCollection = models.UserTableCollection;

  var views = App.module('views'),
      Table = views.Table,
      UserAvatar = views.UserAvatar;

  var NoUserRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    className : 'empty',
    template : function() {
      return _.template('<td colspan="2"><%- empty %></td>', { empty : I18n.t('jst.usersTable.empty') });
    }
  });

  var UserRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : 'usersTable/row',

    ui : {
      name : '.name',
      createdAt : '.createdAt'
    },

    onRender : function() {
      this.renderUser();
      this.ui.createdAt.text(Format.datetime.long(new Date(this.model.get('created_at'))));
    },

    renderUser : function() {
      new UserAvatar({ model : this.model, size : 'small', el : this.ui.name }).render();
    }
  });

  var UsersTableView = Tableling.Bootstrap.TableView.extend({

    template : 'usersTable/table',
    itemView : UserRow,
    itemViewContainer : 'tbody',
    emptyView : NoUserRow
  });

  var UsersTable = Table.extend({

    config : {
      pageSize : 25,
      sort : [ 'name asc' ]
    },
    
    tableView : UsersTableView,
    tableViewOptions : {
      collection : new UserTableCollection()
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new UsersTable());
  });
});
