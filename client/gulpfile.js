var _ = require('underscore'),
    autoPrefixer = require('gulp-autoprefixer'),
    clean = require('gulp-clean'),
    fs = require('fs'),
    gulp = require('gulp'),
    ngAnnotate = require('gulp-ng-annotate'),
    nodemon = require('gulp-nodemon'),
    plumber = require('gulp-plumber'),
    less = require('gulp-less'),
    livereload = require('gulp-livereload'),
    minimatch = require('minimatch'),
    path = require('path'),
    rename = require('gulp-rename'),
    runSequence = require('run-sequence'),
    slm = require('slm'),
    gslm = require('gulp-slm'),
    stylus = require('gulp-stylus'),
    templateLocals = require('./lib/templateLocals'),
    through = require('through2'),
    util = require('gulp-util'),
    watch = require('gulp-watch');

var PluginError = util.PluginError;

var gulpPlugins = require('./lib/gulp'),
    log = gulpPlugins.log;

var markdown = require('slm-markdown');
markdown.register(slm.template);

var root = __dirname;

function buildAutoPrefixer() {
  return autoPrefixer();
}

function compileSlm(file, enc, cb) {
  var opts = {};
  opts.filename = file.path;

  file.path = util.replaceExtension(file.path, '.html');

  if (file.isStream()) {
    return cb(new PluginError('gulp-slm', 'Streaming not supported'));
  }

  if (file.isBuffer()) {
    try {
      var locals = templateLocals;
      file.contents = new Buffer(slm.compile(String(file.contents))(locals));
    } catch(e) {
      e.message = 'Slim template error in ' + path.relative(root, file.path) + '; ' + e.message;
      return cb(new PluginError('gulp-slm', e));
    }
  }

  cb(null, file);
};

var assetTypes = {
  js: {
    extension: 'js',
    compiledExtension: 'js',
    paths: [
      'new-boot.js',
      'routes.js',
      'components/**/*.js',
      'filters/**/*.js',
      'initializers/**/*.js',
      'pages/**/*.js',
      'services/**/*.js',
      'validations/**/*.js',
      'vendor/**/*.js',
      'widgets/**/*.js'
    ],
    compile: function(chain) {
      return chain.pipe(ngAnnotate());
    }
  },
  less: {
    extension: 'less',
    compiledExtension: 'css',
    paths: [
      'styles/*.less'
    ],
    compile: function(chain) {
      return chain.pipe(less({
        paths: [ path.join(root, 'public', 'vendor', 'stylesheets') ]
      })).pipe(buildAutoPrefixer());
    }
  },
  styl: {
    extension: 'styl',
    compiledExtension: 'css',
    paths: [
      'components/**/*.styl',
      'pages/**/*.styl',
      'styles/**/*.styl',
      'widgets/**/*.styl'
    ],
    compile: function(chain) {
      return chain.pipe(stylus()).pipe(buildAutoPrefixer());
    }
  },
  slm: {
    extension: 'slim',
    compiledExtension: 'html',
    paths: [
      'index.html.slim',
      'components/**/*.slim',
      'pages/**/*.slim',
      'services/**/*.slim',
      'widgets/**/*.slim'
    ],
    compile: function(chain) {
      return chain.pipe(through.obj(compileSlm));
    }
  }
};

function getAssetType(type) {
  if (!assetTypes[type]) {
    throw new Error('Unknown asset type ' + type);
  }

  return assetTypes[type];
}

function getCompiledAssetPath(originalPath) {
  return path.join(root, 'public', path.relative(root, originalPath).replace(/\.[a-zA-Z]+$/, ''));
}

function compile(type) {

  var assetType = getAssetType(type),
      chain = gulp.src(assetType.paths, { base: root }).pipe(plumber());

  return compileChain(chain, type);
}

function compileChain(chain, type) {

  var assetType = getAssetType(type);

  if (assetType.compile) {
    chain = assetType.compile(chain);
  }

  if (assetType.compiledExtension && assetType.compiledExtension != assetType.extension) {
    var stripExtensionRegexp = new RegExp('\\.' + assetType.compiledExtension + '$');
    chain = chain.pipe(rename(function(path) {
      path.basename = path.basename.replace(stripExtensionRegexp, '');
      return path;
    }));
  }

  chain = chain.pipe(gulp.dest('public'));

  chain = chain.pipe(through.obj(function(file, enc, cb) {
    if (file.isNull()) {
      return cb(null, file);
    }

    var compiledPath = path.relative(root, file.path),
        originalPath = compiledPath.replace(/public\//, '') + '.' + assetType.extension;

    util.log(util.colors.cyan(originalPath) + ' -> ' + util.colors.cyan(compiledPath));

    cb(null, file);
  }));

  chain = chain.on('error', util.log);

  return chain;
}

function deleteAsset(filePath) {

  var compiledAssetPath = getCompiledAssetPath(filePath),
      relativePath = path.relative(root, compiledAssetPath);

  try {
    fs.unlinkSync(compiledAssetPath);
    util.log(util.colors.green('deleted ' + relativePath));
  } catch (err) {
    util.log(util.colors.yellow('could not delete ' + relativePath));
  }
}

gulp.task('clean', function() {
  return gulp.src('public/*', { read: false })
    .pipe(clean());
});

_.each(assetTypes, function(assetType, type) {
  gulp.task('compile-' + type, function() {
    return compile(type);
  });
});

gulp.task('compile', function(callback) {
  runSequence([ 'compile-js', 'compile-less', 'compile-styl' ], 'compile-slm', callback);
});

var staticAssets = [
  // javascripts
  { src: 'underscore/underscore.js', dest: 'javascripts/underscore.js' },
  { src: 'jquery/dist/jquery.js', dest: 'javascripts/jquery.js' },
  { src: 'moment/moment.js', dest: 'javascripts/moment.js' },
  { src: 'jvent/dist/jvent.js', dest: 'javascripts/jvent.js' },
  { src: 'js-yaml/dist/js-yaml.js', dest: 'javascripts/js-yaml.js' },
  { src: 'jqcloud2/dist/jqcloud.js', dest: 'javascripts/jqcloud2.js' },
  { src: 'Chart.js/Chart.js', dest: 'javascripts/chart.js' },
  { src: 'zeroclipboard/dist/ZeroClipboard.js', dest: 'javascripts/zero-clipboard.js' },
  { src: 'dropzone/dist/dropzone.js', dest: 'javascripts/dropzone.js' },
  { src: 'angular/angular.js', dest: 'javascripts/angular.js' },
  { src: 'angular-animate/angular-animate.js', dest: 'javascripts/angular-animate.js' },
  { src: 'angular-sanitize/angular-sanitize.js', dest: 'javascripts/angular-sanitize.js' },
  { src: 'angular-ui-router/release/angular-ui-router.js', dest: 'javascripts/angular-ui-router.js' },
  { src: 'angular-ui-router-title/angular-ui-router-title.js', dest: 'javascripts/angular-ui-router-title.js' },
  { src: 'angular-bootstrap/ui-bootstrap-tpls.js', dest: 'javascripts/angular-ui-bootstrap-tpls.js' },
  { src: 'a0-angular-storage/dist/angular-storage.js', dest: 'javascripts/angular-local-storage.js' },
  { src: 'angular-moment/angular-moment.js', dest: 'javascripts/angular-moment.js' },
  { src: 'angular-base64/angular-base64.js', dest: 'javascripts/angular-base64.js' }, // TODO: remove if unused
  { src: 'angular-smart-table/dist/smart-table.js', dest: 'javascripts/angular-smart-table.js' },
  { src: 'angular-gravatar/build/angular-gravatar.js', dest: 'javascripts/angular-gravatar.js' },
  { src: 'ngInfiniteScroll/build/ng-infinite-scroll.js', dest: 'javascripts/angular-ng-infinite-scroll.js' },
  { src: 'angular-jqcloud/angular-jqcloud.js', dest: 'javascripts/angular-jqcloud.js' },
  { src: 'ng-clip/src/ngClip.js', dest: 'javascripts/angular-ng-clip.js' },
  { src: 'angular-loading-bar/build/loading-bar.js', dest: 'javascripts/angular-loading-bar.js' },
  { src: 'angular-ui-select/dist/select.js', dest: 'javascripts/angular-ui-select.js' },
  { src: 'angular-chart.js/dist/angular-chart.js', dest: 'javascripts/angular-chart.js' },
  { src: 'angular-truncate/src/truncate.js', dest: 'javascripts/angular-truncate.js' },
  { src: 'angular-scroll/angular-scroll.js', dest: 'javascripts/angular-scroll.js' },
  { src: 'drop-ng/src/drop-ng.js', dest: 'javascripts/drop-ng.js' },
  { src: 'tether/dist/js/tether.js', dest: 'javascripts/tether.js' },
  { src: 'tether-drop/dist/js/drop.js', dest: 'javascripts/tether-drop.js' },
  { src: 'bootstrap/js/tooltip.js', dest: 'javascripts/bootstrap-tooltip.js' },
  { src: 'bootstrap/js/popover.js', dest: 'javascripts/bootstrap-popover.js' },
  // stylesheets
  { src: 'normalize.css/normalize.css', dest: 'stylesheets/normalize.css' },
  { src: 'jqcloud2/dist/jqcloud.css', dest: 'stylesheets/jqcloud2.css' },
  { src: 'angular-loading-bar/build/loading-bar.css', dest: 'stylesheets/angular-loading-bar.css' },
  { src: 'angular-ui-select/dist/select.css', dest: 'stylesheets/angular-ui-select.css' },
  { src: 'angular-chart.js/dist/angular-chart.css', dest: 'stylesheets/angular-chart.css' },
  { src: 'dropzone/dist/dropzone.css', dest: 'stylesheets/dropzone.css' },
  { cwd: 'bootstrap/less', src: '**/*.less', dest: 'stylesheets/bootstrap' },
  { cwd: 'font-awesome/less', src: '**/*.less', dest: 'stylesheets/font-awesome' },
  // fonts
  { cwd: 'bootstrap/dist/fonts', src: '**/*.*', dest: 'fonts' },
  { cwd: 'font-awesome/fonts', src: '**/*.*', dest: 'fonts' },
  // flash
  { src: 'zeroclipboard/dist/ZeroClipboard.swf', dest: 'flash/zero-clipboard.swf' }
];

gulp.task('vendor-static-files', function() {

  var files = _.pluck(_.filter(staticAssets, function(asset) {
    return !asset.cwd;
  }), 'src');

  return gulp.src(files, { base: 'bower_components', cwd: 'bower_components' }).pipe(rename(function(filePath) {

    var asset = _.findWhere(staticAssets, { src: path.join(filePath.dirname, filePath.basename) + filePath.extname });

    filePath.dirname = path.dirname(asset.dest);
    filePath.basename = path.basename(asset.dest, path.extname(asset.dest));
    filePath.extname = path.extname(asset.dest);

    util.log(util.colors.cyan(path.join('bower_components', asset.src)) + ' -> ' + util.colors.cyan(path.join('vendor', asset.dest)));

    return filePath;
  })).pipe(gulp.dest('vendor'));
});

gulp.task('vendor-static-directories', function() {

  var files = _.map(_.filter(staticAssets, function(asset) {
    return asset.cwd;
  }), function(asset) {
    return path.join(asset.cwd, asset.src);
  });

  return gulp.src(files, { base: 'bower_components', cwd: 'bower_components' }).pipe(rename(function(filePath) {

    var relativePath = path.join(filePath.dirname, filePath.basename) + filePath.extname;

    var asset = _.find(staticAssets, function(asset) {
      return asset.cwd && minimatch(relativePath, path.join(asset.cwd, asset.src));
    });

    filePath.dirname = path.join(asset.dest, path.relative(asset.cwd, filePath.dirname));

    util.log(util.colors.cyan(path.join('bower_components', relativePath)) + ' -> ' + util.colors.cyan(path.join('vendor', filePath.dirname, path.basename(relativePath))));

    return filePath;
  })).pipe(gulp.dest('vendor'));
});

gulp.task('vendor-tmp', function() {
  return gulp.src('*.less', { cwd: '../vendor/assets/stylesheets/bootstrap-spacelab-theme' })
    .pipe(gulp.dest('vendor/stylesheets/bootstrap-spacelab-theme'));
});

gulp.task('vendor', [ 'vendor-static-files', 'vendor-static-directories', 'vendor-tmp' ]);

gulp.task('copy-images', function() {
  return gulp.src(root + '/images', { base: root + '/images' })
    .pipe(gulp.dest('public/images'));
});

gulp.task('copy-vendor', function() {
  return gulp.src(path.join(root, 'vendor', '**/*.*'), { base: path.join(root, 'vendor') })
    .pipe(gulp.dest('public/vendor'));
});

gulp.task('copy', [ 'copy-images', 'copy-vendor' ]);

gulp.task('watch', _.reduce(assetTypes, function(memo, assetType, type) {
  memo.push('watch-' + type);
  return memo;
}, []));

_.each(assetTypes, function(assetType, type) {
  gulp.task('watch-' + type, function() {
    return watch(assetType.paths, function(file) {
      if (file.event == 'add' || file.event == 'change') {
        compileChain(gulp.src(file.path, { base: root }).pipe(plumber()), type).pipe(livereload());
      } else {
        deleteAsset(file.path);
      }
    });
  });
});

gulp.task('develop', function() {
  livereload.listen();

  nodemon({
    script: 'app.js',
    ext: 'js',
    watch: [ 'app.js', 'config/**/*.js', 'lib/**/*.js' ],
    stdout: false
  }).on('readable', function() {
    this.stdout.on('data', function(chunk) {
      if (/^Express server listening on port/.test(chunk)) {
        livereload.changed(__dirname);
      }
    });
    this.stdout.pipe(process.stdout);
    this.stderr.pipe(process.stderr);
  });
});

gulp.task('init', function(callback) {
  runSequence('clean', 'vendor', 'copy', 'compile', callback);
});

gulp.task('default', [
  'develop',
  'watch'
]);