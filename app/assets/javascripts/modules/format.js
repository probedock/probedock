angular.module('probedock.format', [])

  .filter('durationFormat', function () {

    var durations = [
      { name: 'd', value: 86400000 },
      { name: 'h', value: 3600000 },
      { name: 'm', value: 60000 },
      { name: 's', value: 1000 },
      { name: 'ms', value: 1 }
    ];

    function findDuration(unit) {

      var duration = _.find(durations, function(d) {
        return d.name == unit;
      });

      if (!duration) {
        throw new Error("Unknown duration unit '" + unit + "'.");
      }

      return duration;
    }

    return function(milliseconds, min, shorten) {

      if (min) {
        var duration = findDuration(min);
        milliseconds = Math.floor(milliseconds / duration.value) * duration.value;
      }

      if (milliseconds <= 0) {
        return '0ms';
      }

      if (shorten) {
        var duration = findDuration(options.shorten);
        var closestDuration = _.find(durations, function(d) {
          return d.value <= duration.value && milliseconds >= d.value;
        });
        if (closestDuration) {
          milliseconds = Math.floor(milliseconds / closestDuration.value) * closestDuration.value;
        }
      }

      return _.inject(durations, function(memo, d) {
        var value = Math.floor(milliseconds / d.value);
        if (value >= 1) {
          milliseconds = milliseconds - value * d.value;
          memo.push(value + d.name);
        }
        return memo;
      }, []).join(' ');
    };
  });

;
