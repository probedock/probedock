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

App.autoModule('projectsTable', function() {

  var models = App.module('models'),
      Project = models.Project,
      ProjectTableCollection = models.ProjectTableCollection;

  var views = App.module('views'),
      Table = views.Table;

  var NoProjectRow = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    className : 'empty',
    template : function() {
      return _.template('<td colspan="4"><%- empty %></td>', { empty : I18n.t('jst.projectsTable.empty') })
    }
  });

  var ProjectRow = Backbone.Marionette.ItemView.extend({
    
    tagName : 'tr',
    template : 'projectsTable/row',

    ui : {
      name : '.name',
      activeTestsCount : '.activeTestsCount',
      apiId : '.apiId',
      createdAt : '.createdAt'
    },

    onRender : function() {
      this.ui.name.html(this.model.link());
      this.ui.activeTestsCount.text(Format.number(this.model.get('activeTestsCount')));
      this.ui.apiId.text(this.model.get('apiId'));
      this.ui.createdAt.text(Format.datetime.long(new Date(this.model.get('createdAt'))));
    }
  });

  var ProjectsTableView = Tableling.Bootstrap.TableView.extend({

    template : 'projectsTable/table',
    itemView : ProjectRow,
    itemViewContainer : 'tbody',
    emptyView : NoProjectRow,
  });

  var ProjectsTable = Table.extend({

    config : {
      pageSize : 15,
      sort : [ 'name asc' ]
    },

    tableView : ProjectsTableView,
    tableViewOptions : {
      collection : new ProjectTableCollection()
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new ProjectsTable(options.config));
  });
});
