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
