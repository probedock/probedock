#!/usr/bin/env rake
# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require File.expand_path('../config/application', __FILE__)

ProbeDock::Application.load_tasks

require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'bower.json', 'package.json', 'probedock.yml', 'client/boot.js.erb', 'client/templates.js.erb', 'spec/javascripts/version.spec.js'
end

if Rails.env != 'production'

  Rake::Task['spec'].enhance do
    Rake::Task['cucumber'].invoke
  end

  Rake::Task['spec'].prerequisites.unshift('spec:server:start')

  require 'probedock-rspec'
  ProbeDockProbe::Tasks.new workspace: 'tmp/probedock'
  Rake::Task['spec'].prerequisites.unshift('spec:probedock:uid')
end
