// Copyright (c) 2012-2014 Lotaris SA
//
// This file is part of Probe Dock.
//
// Probe Dock is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Probe Dock is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
var projectBase = {
  _links: {
    self: {
      href: 'http://example.com/project'
    },
    alternate: {
      href: 'http://example.com/project.html',
      type: 'text/html'
    }
  },
  name: 'A project',
  apiId: '123456789012',
  urlToken: 'a_project',
  activeTestsCount: 3,
  deprecatedTestsCount: 1,
  createdAt: new Date().getTime()
};

describe("Project", function() {

  var Project = App.models.Project,
      TestKey = App.models.TestKey,
      project = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    project = new Project(projectBase);
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(project);
  });

  it("should use its API ID as the ID", function() {
    this.meta = { rox: { key: '3fc6d0a5a965'} };
    expect(project.id).toBe(projectBase.apiId);
  });

  it("should have many test keys", function() {
    this.meta = { rox: { key: 'b40c06fb3d4a' } };
    expect(Project).toHaveBackboneRelation({ type: Backbone.HasMany, key: 'freeTestKeys', relatedModel: 'TestKey', includeInJSON: false });
  });

  it("should return its self link as its url", function() {
    this.meta = { rox: { key: '0b348a2dd438' } };
    expect(project.url()).toBe('http://example.com/project');
  });

  it("should build a link tag for its alternate path", function() {
    this.meta = { rox: { key: '28f0306f5568' } };
    expect(project.linkTag()).toLinkTo('http://example.com/project.html', projectBase.name);
  });
});

describe("Projects", function() {

  var Project = App.models.Project,
      Projects = App.models.Projects;

  it("should use the Project model", function() {
    this.meta = { rox: { key: 'd59a735a0cc6' } };
    expect(getEmbeddedRelation(Projects, 'item').relatedModel).toBe(Project);
  });
});
