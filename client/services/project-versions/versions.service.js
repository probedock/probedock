angular.module('probedock.projectVersions').factory('projectVersions', function() {

  function compareVersion(v1, v2) {
    var versionRegex = /(\d+)?(.*)?/;

    // Prepare parts for both versions
    var v1Parts = v1.split('.'),
        v2Parts = v2.split('.');

    // Pad versions with 0
    while (v1Parts.length < v2Parts.length) v1Parts.push("0");
    while (v2Parts.length < v1Parts.length) v2Parts.push("0");

    for (var i = 0; i < v1Parts.length; ++i) {
      // V1 is longer than V2 and all previous V1 parts was greater than V2
      if (v2Parts.length == i) {
        return 1;
      }

      // Split the subparts to digit and string part
      var v1Subparts = versionRegex.exec(v1Parts[i]),
          v2Subparts = versionRegex.exec(v2Parts[i]);

      // If no numeric part for both of subparts, we continue to evaluate otherwise we evaluate which one is not present
      if (_.isNull(v1Subparts[i]) && _.isNull(v2Subparts[i])) {
        continue;
      } else if (_.isNull(v1Subparts[i]) || _.isNull(v2Subparts[i])) {
        return v1Subparts[i] ? 1 : -1;
      }

      // Check if numeric parts are equals
      if (v1Subparts[1] == v2Subparts[1]) {
        // Check if there is string parts to compare
        if  (v1Subparts[2] && v2Subparts[2]) {
          // Strings are the same, continue the comparison
          if (v1Subparts[2] == v2Subparts[2]) {
            continue;
          } else {
            return v1Subparts[2] < v2Subparts[2] ? -1 : 1;
          }
        } else if (v1Subparts[2] || v2Subparts[2]) {
          // V1 is greater if there is a string subpart for it
          // otherwise, V2 has it and is greater than V1
          return v1Subparts[2] ? 1 : -1;
        } else {
          // No subparts but numeric parts are equals
          continue;
        }
      } else { // Compare the numbers
        var v1NumPart = parseInt(v1Subparts[1], 10),
            v2NumPart = parseInt(v2Subparts[1], 10);

        return v1NumPart < v2NumPart ? -1 : 1;
      }
    }

    return 0;
  }

  return {
    // FIXME: Replace this comparator function by server side implementation
    // Based on topic: http://stackoverflow.com/questions/6832596/how-to-compare-software-version-number-using-js-only-number
    compare: compareVersion,

    // FIXME: Replace this sort function by server side implementation
    sort: function(collection) {
      if (_.isArray(collection)) {
        return collection.sort(function(v1, v2) {
          return compareVersion(v1.name, v2.name);
        });
      }

      return null;
    }
  };
});
