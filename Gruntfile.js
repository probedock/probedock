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
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    jasmine: {
      default: {
        src: 'tmp/jasmine/assets/application-*.js',
        options: {
          specs: 'spec/javascripts/**/*.spec.js',
          helpers: 'spec/javascripts/helpers/**/*.js',
          vendor: 'spec/javascripts/vendor/**/*.js'
        }
      }
    },

    'rox-setup': {
      default: {
        roxConfig: {
          project: {
            category: 'Jasmine'
          }
        }
      }
    },

    'rox-publish': {
      default: {
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-jasmine');

  require('./spec/javascripts/support/rox')(grunt);

  grunt.registerTask('default', [ 'rox-setup', 'jasmine', 'rox-publish' ]);
};
