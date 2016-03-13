var _ = require('underscore'),
    gutil = require('gulp-util'),
    handlebars = require('handlebars'),
    PluginError = gutil.PluginError,
    through = require('through2');

// Consts
const PLUGIN_NAME = 'gulp-prefixer';

// Plugin level function(dealing with files)
function log(prefixText) {

  // Creating a stream through which each file will pass
  return through.obj(function(file, enc, cb) {
    if (file.isNull()) {
      // return empty file
      return cb(null, file);
    }

    console.log('-> ' + JSON.stringify(file));

    /*if (file.isBuffer()) {
      file.contents = Buffer.concat([prefixText, file.contents]);
    }

    if (file.isStream()) {
      file.contents = file.contents.pipe(prefixStream(prefixText));
    }*/

    cb(null, file);

  });

}

function compileHandlebar(options) {

  options = _.extend({}, options);
  var locals = _.extend({}, options.locals);

  return through.obj(function(file, enc, cb) {
    if (file.isNull()) {
      return cb(null, file);
    } else if (file.isStream()) {
      return this.emit('error', new PluginError('gulp-handlebars', 'Streams not supported!'));
    }

    var template = handlebars.compile(String(file.contents));
    file.contents = new Buffer(template(locals));

    cb(null, file);
  });
}

// Exporting the plugin main function
module.exports = {
  log: log,
  handlebars: compileHandlebar
};
