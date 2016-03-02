// Copyright (c) 2012-2014 Lotaris SA
//
// This file is part of ProbeDock.
//
// ProbeDock is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ProbeDock is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
module.exports = function(grunt) {

  grunt.initConfig({

    pkg: grunt.file.readJSON('package.json'),

    copy: {
      assets: {
        files: [
          // javascripts
          { nonull: true, src: 'bower_components/underscore/underscore.js', dest: 'vendor/assets/javascripts/underscore.js' },
          { nonull: true, src: 'bower_components/jquery/dist/jquery.js', dest: 'vendor/assets/javascripts/jquery.js' },
          { nonull: true, src: 'bower_components/moment/moment.js', dest: 'vendor/assets/javascripts/moment.js' },
          { nonull: true, src: 'bower_components/jvent/dist/jvent.js', dest: 'vendor/assets/javascripts/jvent.js' },
          { nonull: true, src: 'bower_components/js-yaml/dist/js-yaml.js', dest: 'vendor/assets/javascripts/js-yaml.js' },
          { nonull: true, src: 'bower_components/jqcloud2/dist/jqcloud.js', dest: 'vendor/assets/javascripts/jqcloud2.js' },
          { nonull: true, src: 'bower_components/Chart.js/Chart.js', dest: 'vendor/assets/javascripts/chart.js' },
          { nonull: true, src: 'bower_components/zeroclipboard/dist/ZeroClipboard.js', dest: 'vendor/assets/javascripts/zero-clipboard.js' },
          { nonull: true, src: 'bower_components/dropzone/dist/dropzone.js', dest: 'vendor/assets/javascripts/dropzone.js' },
          { nonull: true, src: 'bower_components/angular/angular.js', dest: 'vendor/assets/javascripts/angular.js' },
          { nonull: true, src: 'bower_components/angular-animate/angular-animate.js', dest: 'vendor/assets/javascripts/angular-animate.js' },
          { nonull: true, src: 'bower_components/angular-sanitize/angular-sanitize.js', dest: 'vendor/assets/javascripts/angular-sanitize.js' },
          { nonull: true, src: 'bower_components/angular-ui-router/release/angular-ui-router.js', dest: 'vendor/assets/javascripts/angular-ui-router.js' },
          { nonull: true, src: 'bower_components/angular-ui-router-title/angular-ui-router-title.js', dest: 'vendor/assets/javascripts/angular-ui-router-title.js' },
          { nonull: true, src: 'bower_components/angular-bootstrap/ui-bootstrap-tpls.js', dest: 'vendor/assets/javascripts/angular-ui-bootstrap-tpls.js' },
          { nonull: true, src: 'bower_components/a0-angular-storage/dist/angular-storage.js', dest: 'vendor/assets/javascripts/angular-local-storage.js' },
          { nonull: true, src: 'bower_components/angular-moment/angular-moment.js', dest: 'vendor/assets/javascripts/angular-moment.js' },
          { nonull: true, src: 'bower_components/angular-base64/angular-base64.js', dest: 'vendor/assets/javascripts/angular-base64.js' }, // TODO: remove if unused
          { nonull: true, src: 'bower_components/angular-smart-table/dist/smart-table.js', dest: 'vendor/assets/javascripts/angular-smart-table.js' },
          { nonull: true, src: 'bower_components/angular-gravatar/build/angular-gravatar.js', dest: 'vendor/assets/javascripts/angular-gravatar.js' },
          { nonull: true, src: 'bower_components/ngInfiniteScroll/build/ng-infinite-scroll.js', dest: 'vendor/assets/javascripts/angular-ng-infinite-scroll.js' },
          { nonull: true, src: 'bower_components/angular-jqcloud/angular-jqcloud.js', dest: 'vendor/assets/javascripts/angular-jqcloud.js' },
          { nonull: true, src: 'bower_components/ng-clip/src/ngClip.js', dest: 'vendor/assets/javascripts/angular-ng-clip.js' },
          { nonull: true, src: 'bower_components/angular-loading-bar/build/loading-bar.js', dest: 'vendor/assets/javascripts/angular-loading-bar.js' },
          { nonull: true, src: 'bower_components/angular-ui-select/dist/select.js', dest: 'vendor/assets/javascripts/angular-ui-select.js' },
          { nonull: true, src: 'bower_components/angular-chart.js/dist/angular-chart.js', dest: 'vendor/assets/javascripts/angular-chart.js' },
          { nonull: true, src: 'bower_components/angular-truncate/src/truncate.js', dest: 'vendor/assets/javascripts/angular-truncate.js' },
          { nonull: true, src: 'bower_components/angular-scroll/angular-scroll.js', dest: 'vendor/assets/javascripts/angular-scroll.js' },
          { nonull: true, src: 'bower_components/drop-ng/src/drop-ng.js', dest: 'vendor/assets/javascripts/drop-ng.js' },
          { nonull: true, src: 'bower_components/tether/dist/js/tether.js', dest: 'vendor/assets/javascripts/tether.js' },
          { nonull: true, src: 'bower_components/tether-drop/dist/js/drop.js', dest: 'vendor/assets/javascripts/tether-drop.js' },
          { nonull: true, src: 'bower_components/bootstrap/js/tooltip.js', dest: 'vendor/assets/javascripts/bootstrap-tooltip.js' },
          { nonull: true, src: 'bower_components/bootstrap/js/popover.js', dest: 'vendor/assets/javascripts/bootstrap-popover.js' },
          // stylesheets
          { nonull: true, src: 'bower_components/normalize.css/normalize.css', dest: 'vendor/assets/stylesheets/normalize.css' },
          { nonull: true, src: 'bower_components/jqcloud2/dist/jqcloud.css', dest: 'vendor/assets/stylesheets/jqcloud2.css' },
          { nonull: true, src: 'bower_components/angular-loading-bar/build/loading-bar.css', dest: 'vendor/assets/stylesheets/angular-loading-bar.css' },
          { nonull: true, src: 'bower_components/angular-ui-select/dist/select.css', dest: 'vendor/assets/stylesheets/angular-ui-select.css' },
          { nonull: true, src: 'bower_components/angular-chart.js/dist/angular-chart.css', dest: 'vendor/assets/stylesheets/angular-chart.css' },
          { nonull: true, src: 'bower_components/dropzone/dist/dropzone.css', dest: 'vendor/assets/stylesheets/dropzone.css' },
          // fonts
          { nonull: true, cwd: 'bower_components/bootstrap/dist/fonts/', src: '**', dest: 'vendor/assets/fonts/', flatten: true, expand: true },
          { nonull: true, cwd: 'bower_components/font-awesome/fonts/', src: '**', dest: 'vendor/assets/fonts/', flatten: true, expand: true },
          // flash
          { nonull: true, src: 'bower_components/zeroclipboard/dist/ZeroClipboard.swf', dest: 'vendor/assets/flash/zero-clipboard.swf' }
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
      },

      fontAwesome: {
        expand: true,
        cwd: 'bower_components/font-awesome/less',
        src: ['**/*less'],
        dest: 'vendor/assets/stylesheets/font-awesome/',
        options: {
          process: function (content) {
            return content
              .replace(/url\(\'@\{fa-font-path\}\//g, 'asset-url(\'')
              .replace(/(\?|&)v=@\{fa-version\}/g, '');
          }
        }
      }
    },

    jshint: {
      all: [ 'app/assets/javascripts/**/*.js', 'Gruntfile.js' ]
    },

    raml2boot: {
      options: {
        standalone: true
      },
      apidoc: {
        files: {
          'doc/api.html': 'doc/api/api.raml'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-raml2boot');

  grunt.registerTask('default', [ 'jshint' ]);
  grunt.registerTask('vendor', [ 'copy:assets', 'copy:bootstrap', 'copy:fontAwesome' ]);
};
