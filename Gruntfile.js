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

  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    copy: {
      assets: {
        files: [
          // javascripts
          { nonull: true, src: 'bower_components/underscore/underscore.js', dest: 'vendor/assets/javascripts/underscore.js' },
          { nonull: true, src: 'bower_components/jquery/dist/jquery.js', dest: 'vendor/assets/javascripts/jquery.js' },
          { nonull: true, src: 'bower_components/angular/angular.js', dest: 'vendor/assets/javascripts/angular.js' },
          { nonull: true, src: 'bower_components/angular-ui-router/release/angular-ui-router.js', dest: 'vendor/assets/javascripts/angular-ui-router.js' },
          { nonull: true, src: 'bower_components/angular-bootstrap/ui-bootstrap-tpls.js', dest: 'vendor/assets/javascripts/angular-ui-bootstrap-tpls.js' },
          { nonull: true, src: 'bower_components/angular-local-storage/dist/angular-local-storage.js', dest: 'vendor/assets/javascripts/angular-local-storage.js' },
          { nonull: true, src: 'bower_components/angular-base64/angular-base64.js', dest: 'vendor/assets/javascripts/angular-base64.js' }, // TODO: remove if unused
          // stylesheets
          { nonull: true, src: 'bower_components/normalize.css/normalize.css', dest: 'vendor/assets/stylesheets/normalize.css' },
          // fonts
          { nonull: true, cwd: 'bower_components/bootstrap/dist/fonts/', src: '**', dest: 'vendor/assets/fonts/', flatten: true, expand: true }
        ]
      },

      bootstrap: {
        expand: true,
        cwd: 'bower_components/bootstrap/less',
        src: ['**/*.less'],
        dest: 'vendor/assets/stylesheets/bootstrap/',
        options: {
          process: function(content) {
            return content
              .replace(/url\(\'\@\{icon-font-path\}\@\{icon-font-name\}/g, 'asset-url(\'glyphicons-halflings-regular')
              .replace(/\@\{icon-font-svg-id\}/g, 'glyphicons_halflingsregular')
              .replace(/\/\*\#.*\*\//, '');
          }
        }
      }
    },

    jshint: {
      all: [ 'app/assets/javascripts/**/*.js', 'Gruntfile.js' ]
    }
  });

  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');

  grunt.registerTask('default', [ 'jshint' ]);
  grunt.registerTask('vendor', [ 'copy:assets', 'copy:bootstrap' ]);
};
