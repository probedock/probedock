angular.module('probedock.slowTestsWidget').controller('SlowTestsContentCtrl', ['$scope', 'api', '$filter', function ($scope, api, $filter) {

  _.defaults($scope, {
    params: {
      categoryId: null,
      versionId: null
    }
  });
  var width = $('.newtests-widget').width() - 80,
    height = 500,
    x,
    y,
    xAxis,
    yAxis,
    colorRange = ["#FF0000", "#EC1300", "#DA2500", "#C73800", "#B54A00", "#A25D00", "#906F00", "#7D8200",
      "#6B9400", "#58A700", "#46B900", "#33CC00"],
    widthBar,
    colorRegression = "#111111",
    colorAverage = "#0000ff",
    colorMedian = "#ff0000",
    colorBar = "#3a87ad";

  $(window).resize(function () {
    width = $('.newtests-widget').width() - 80;
    d3.select('.slowtests-chart').selectAll('*').remove();
    setup('.slowtests-chart', $scope.testSelected.category, $scope.testSelected.data);
  });

  var tip = d3.tip()
    .attr('class', 'd3-tip')
    .offset([-10, 0])
    .html(function (d) {
      return "<p><strong>" + d.test + "</strong></p><p>min: " + d.min + "  avg: " + $filter('number')(d.avg, 3) + " max: " + d.max + "</p>";
    });

  /**
   * Initialize the svg
   * @param element class or ID to display the chart
   * @param category the name of the category
   * @param data the data
   */
  var setup = function (element, category, data) {
    var svg = d3.select(element)
      .append("div")
      .attr("class", category)
      .append("svg")
      .attr('width', width + 100)
      .attr('height', height + 100)
      .append("g")
      .attr("transform", "translate(50, 20)");

    svg.call(tip);

    x = d3.scale.ordinal()
      .rangeRoundBands([0, width], .1);

    y = d3.scale.linear()
      .range([height, 0]);

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .ticks(20, "ms");


    chart(data, svg, category);
  };

  /**
   * Generate the chart
   * @param value the data
   * @param svg the svg
   * @param category name of the category
   */
  var chart = function (value, svg, category) {
    x.domain(value.map(function (d, i) {
      return i;
    }));

    var max = d3.max(value, function (d) {
      return d.max;
    });
    y.domain([d3.min(value, function (d) {
      return d.min;
    }), max]);

    // Define the width of the bar
    widthBar = x.rangeBand() - x.rangeBand() * 0.3;

    // Set title
    svg.append("g")
      .attr("class", "title-category")
      .call(xAxis)
      .append("text")
      .attr("x", width / 2 + 50 + 'px')
      .attr("dx", 0)
      .style("text-anchor", "end")
      .text(category);

    // Set x-axis
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    // Set y-axis
    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("y", 0)
      .attr("dy", 0)
      .attr("x", "-10 ")
      .style("text-anchor", "end")
      .text("ms");


    // Generate bar
    var bar = svg.selectAll(".bar")
      .data(value)
      .enter()
      .append("rect")
      .attr("class", "bar")
      .attr("fill", colorBar)
      .attr("x", function (d, i) {
        return x(i);
      })
      .attr("width", widthBar)
      .attr("y", function (d) {
        return y(d.max);
      })
      .attr("height", function (d) {
        return y(d.min) - y(d.max);
      }).on('mouseover', tip.show)
      .on('mouseout', tip.hide);

    svg.selectAll(".text-duration-last-run")
      .data(value)
      .enter()
      .append("text")
      .attr("class", "text-duration-last-run")
      .attr("x", function (d, i) {
        return x(i);
      })
      .attr("y", function (d) {
        return y(d.max) - 5 + "px";
      })
      .text(function (d) {
        return "Last run : " + d.durations[d.durations.length - 1];
      });

    if (width > 500) {

      /**
       * Count the number of occurrence
       * @param array duration array
       * @param duration the duration in ms
       * @returns {number} The number of occurence for duration
       */
      var countOccurrenceDuration = function (array, duration) {
        var occurs = 0;

        for (var i = 0; i < array.length; i++) {
          if (array[i] === duration) {
            occurs++;
          }
        }

        return occurs;
      };

      // Retrieve data for circle
      var circles = [];
      angular.forEach(value, function (test, pos) {
        var tests2 = test.tests.reduce(function (nbrCount, current) {
          var tmp = {};
          tmp.nbr = countOccurrenceDuration(test.durations, current.duration);
          tmp.duration = current.duration;
          tmp.test = test.test;
          tmp.pos = pos;
          if (current.success) {
            tmp.success = 1;
          } else {
            tmp.success = 0;
          }
          nbrCount[Object.keys(nbrCount).length] = tmp;
          return nbrCount;
        }, {});

        circles.push(tests2);
      });

      // Object to Array
      circles = Object.keys(circles).map(function (k) {
        return circles[k]
      });

      // Generate color range
      var colorCircle = d3.scale.quantile()
        .range(colorRange)
        .domain([0, 50, 100]);

      // Generate circles
      angular.forEach(circles, function (c) {
        // Object to Array
        c = Object.keys(c).map(function (k) {
          return c[k]
        });

        // Define the min/max size
        var sizeCircle = d3.scale.linear()
          .range([5, 15])
          .domain([0, d3.max(c, function (d) {
            return d.nbr;
          })]);

        svg.selectAll('.circle')
          .data(c)
          .enter()
          .append('circle')
          .attr('cy', function (d) {
            return y(d.duration);
          })
          .attr('cx', function (d) {
            return x(d.pos) + x.rangeBand() - x.rangeBand() * 0.1;
          })
          .attr('fill', function (d) {
            return colorCircle((d.success / d.nbr) * 100);
          })
          .attr('stroke', '#ffffff')
          .attr('stroke-width', '0.5px')
          .attr('r', function (d) {
            return sizeCircle(d.nbr);
          });
      });
    }

    // Generate regression line
    angular.forEach(value, function (test, index) {
      var previousX = x(index) - 1;
      for (var r = 0; r < test.regression.length - 1; r++) {
        svg.append("line")
          .attr("class", "regression")
          .attr("stroke", colorRegression)
          .attr("x1", previousX)
          .attr("y1", y(test.regression[r]))
          .attr("x2", previousX += widthBar / test.regression.length)
          .attr("y2", y(test.regression[r + 1]));

      }
    });

    // Median line
    svg.selectAll(".line")
      .data(value)
      .enter()
      .append("line")
      .attr("class", "median")
      .attr("stroke", colorMedian)
      .attr("x1", function (d, i) {
        return x(i);
      })
      .attr("y1", function (d) {
        var durations = d.durations;
        durations.sort(d3.ascending);
        return y(d3.median(durations));
      })
      .attr("x2", function (d, i) {
        return x(i) + widthBar;
      })
      .attr("y2", function (d) {
        var durations = d.durations;
        durations.sort(d3.ascending);
        return y(d3.median(durations));
      });

    // Average line
    svg.selectAll(".line")
      .data(value)
      .enter()
      .append("line")
      .attr("class", "avg")
      .attr("stroke", colorAverage)
      .attr("x1", function (d, i) {
        return x(i);
      })
      .attr("y1", function (d) {
        return y(d.avg);
      })
      .attr("x2", function (d, i) {
        return x(i) + widthBar;
      })
      .attr("y2", function (d) {
        return y(d.avg);
      });

    // Legend
    svg.append("line")
      .attr("class", "legend-regression")
      .attr("stroke", colorRegression)
      .attr("stroke-width", "2px")
      .attr("x1", 0)
      .attr("y1", height + 45)
      .attr("x2", 10)
      .attr("y2", height + 45);

    svg.append("text")
      .attr("y", height + 50)
      .attr("x", 20)
      .text("Regression");

    svg.append("line")
      .attr("class", "legend-avg")
      .attr("stroke", colorAverage)
      .attr("stroke-width", "2px")
      .attr("x1", 100)
      .attr("y1", height + 45)
      .attr("x2", 110)
      .attr("y2", height + 45);

    svg.append("text")
      .attr("y", height + 50)
      .attr("x", 120)
      .text("Average");

    svg.append("line")
      .attr("class", "legend-median")
      .attr("stroke", colorMedian)
      .attr("stroke-width", "2px")
      .attr("x1", 200)
      .attr("y1", height + 45)
      .attr("x2", 210)
      .attr("y2", height + 45);

    svg.append("text")
      .attr("y", height + 50)
      .attr("x", 220)
      .text("Median");
  };

  $scope.$watch('params.versionId', function () {
    console.log('params', $scope.params);
    if ($scope.params.versionId !== null) {
      $scope.getDurationTest();
    }
  }, true);

  /**
   * When the category change, generate a new graph
   * @param test
   */
  $scope.changeCategory = function (test) {
    $scope.testSelected = test;
    $scope.category = test.category;
    d3.select('.slowtests-chart').selectAll('*').remove();
    setup('.slowtests-chart', test.category, test.data);
  };

  /**
   * Request the api for get the duration for each test
   */
  $scope.getDurationTest = function () {
    api({
      url: '../vizapi/testsResult/duration?version=' + $scope.params.versionId + "&project=" + $scope.project.id + "&organization=" + $scope.organization.id
    }).then(function (res) {
      $scope.data = res.data;
      d3.select('.slowtests-chart').selectAll('*').remove();
      $scope.category = $scope.data[0];
      $scope.testSelected = $scope.data[0];
      setup('.slowtests-chart', $scope.data[0].category, $scope.data[0].data);
    });
  };

}]);