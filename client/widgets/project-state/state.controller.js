angular.module('probedock.projectStateWidget').controller('ProjectStateContentCtrl', ['$scope', 'api', '$filter', function ($scope, api, $filter) {

    var width = $('.projectState-widget').width() - 60,
        height = 290,
        colorRange = ["#FF0000", "#EC1300", "#DA2500", "#C73800", "#B54A00", "#A25D00", "#906F00", "#7D8200",
            "#6B9400", "#58A700", "#46B900", "#33CC00"],
        treemapChart,
        tooltip;

    $(window).resize(function () {
        width = $('.newtests-widget').width() - 60;
        treemapChart.remove();
        setup('.projectState-chart');
        chart($scope.tree);
    });

    /**
     * Setup the treemap
     * @param element class or ID to display the treemap
     */
    var setup = function (element) {
        treemapChart = d3.select(element)
            .append('div')
            .attr('width', width)
            .attr('height', height);
    };

    /**
     * Generate the treemap
     * @param tree data
     */
    var chart = function (tree) {

        // Set color
        var color = d3.scale.quantile()
            .range(colorRange)
            .domain([0, 50, 100]);

        // Set treemap
        var treemap = d3.layout.treemap()
            .size([width, height])
            .sticky(true)
            .value(function (d) {
                return d.nbTests;
            });

        if (tooltip) {
            tooltip.remove();
        }

        // Create node
        var node = treemapChart.datum(tree).selectAll(".node")
            .data(treemap.nodes)
            .enter().append("div")
            .attr("class", "node")
            .call(position)
            .style("background-color", function (d) {
                return d.name === 'projects' ? '#fff' : color(d.ratio);
            })
            .on('mouseover', function (d) {
                if (d.name !== 'projects') {
                    if (tooltip) {
                        tooltip.remove();
                    }
                    tooltip = d3.select('.projectState-widget')
                        .append('div')
                        .attr('class', 'node-tooltip')
                        .html(tooltipHTMLForProject(d))
                        .style('left', function () {
                            return d.x + (Math.max(0, d.dx - 1) / 2) - 10 + 'px';
                        })
                        .style('top', function () {
                            return d.y + (Math.max(0, d.dy - 1) / 2) + 'px';
                        });
                }
            })
            .append('div')
            .style("font-size", function (d) {
                // compute font size based on sqrt(area)
                return Math.max(16, 0.10 * Math.sqrt(d.area)) + 'px';
            })
            .text(function (d) {
                return d.children ? null : d.name;
            });


        /**
         * Generate the tooltip text
         * @param d node
         * @returns {string} test
         */
        function tooltipHTMLForProject(d) {
            return '<p><strong>' + d.name + '</strong></p><p>' + d.version + '</p><p>' + $filter('number')(d.nbTests) +
                ' tests</p><p>' + $filter('number')(d.nbSuccess) + ' success</p>';
        }

        /**
         * Set node position
         */
        function position() {
            this.style("left", function (d) {
                return d.x + 20 + "px"; // add 20 for margin
            })
                .style("top", function (d) {
                    return d.y + "px";
                })
                .style("width", function (d) {
                    return Math.max(0, d.dx - 1) + "px";
                })
                .style("height", function (d) {
                    return Math.max(0, d.dy - 1) + "px";
                });
        }
    };

    /**
     * Get all projects or some project from an organization
     * @param projects list of project
     */
    $scope.getProjects = function (projects) {
        $scope.projectChoices = projects;
        var list = '';
        if (projects && projects.length > 0) {
            list += '&projects=';
            angular.forEach(projects, function (project) {
                list += project.name + ',';
            });
        }

        // Request to API
        api({
            url: '../vizapi/projects?organization=' + $scope.organization.displayName + list
        }).then(function (res) {
            treemapChart.remove();
            setup('.projectState-chart');

            if ($scope.projects.length === 0) {
                $scope.projects = res.data;
            }

            // Create a tree
            $scope.tree = {
                name: 'projects',
                children: res.data
            };
            chart($scope.tree);
        });
    };

    setup('.projectState-chart');
    $scope.projects = [];

    $scope.getProjects();

}]);