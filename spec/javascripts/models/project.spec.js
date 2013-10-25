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

var projectBase = {
  name: 'A project',
  apiId: '123456789012',
  urlToken: 'a_project',
  activeTestsCount: 3,
  deprecatedTestsCount: 1,
  createdAt: new Date().getTime()
};

describe("Project", function() {

  var models = App.module('models'),
      Project = models.Project,
      TestKey = models.TestKey,
      TestKeyCollection = models.TestKeyCollection,
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
    expect(Project).toHaveBackboneRelation({ type: Backbone.HasMany, key: 'testKeys', relatedModel: TestKey, collectionType: TestKeyCollection });
  });

  it("should return its path", function() {
    this.meta = { rox: { key: '0b348a2dd438' } };
    expect(project.path()).toBe('/en/projects/' + projectBase.urlToken);
  });

  it("should return a link to its path", function() {
    this.meta = { rox: { key: '28f0306f5568' } };
    expect(project.link()).toLinkTo('/en/projects/' + projectBase.urlToken, projectBase.name);
  });
});

describe("ProjectCollection", function() {

  var models = App.module('models'),
      Project = models.Project,
      ProjectCollection = models.ProjectCollection,
      col = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    col = new ProjectCollection();
  });

  it("should use the Project model", function() {
    this.meta = { rox: { key: 'd59a735a0cc6' } };
    expect(ProjectCollection.prototype.model).toBe(Project);
  });
});
