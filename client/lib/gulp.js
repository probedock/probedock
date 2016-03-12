// through2 is a thin wrapper around node transform streams
var gutil = require('gulp-util'),
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

// Exporting the plugin main function
module.exports = {
  log: log
};
