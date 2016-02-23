_.isPresent = function(value) {
  if (!value) {
    return false;
  }

  if (_.isString(value)) {
    return !!value.trim().length;
  } else if (value.length !== undefined) {
    return !!value.length;
  } else {
    return true;
  }
};

_.isBlank = function(value) {
  return !_.isPresent(value);
};

// Code from: http://stackoverflow.com/a/6491621
_.deepFind = function(obj, path) {
  path = path.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
  path = path.replace(/^\./, '');           // strip a leading dot

  var a = path.split('.');

  for (var i = 0, n = a.length; i < n; ++i) {
    var k = a[i];
    if (k in obj) {
      obj = obj[k];
    } else {
      return;
    }
  }

  return obj;
};