/* Dependencies: jquery, flot, flottime, flotlabel, gaugemin */

    //Draws the chart for the project or versions. (Flot)
    function drawChart(dataFromJson, placeholder){
        var data = dataFromJson;
        var chartHtmlElement = $('#' + placeholder);
        var graphData = [{
            // Planned Value 
            data: data.pv,
            label: "Planned Value",
            color: '#0f75bc'
        }, {
            // Actual Cost  
            data: data.ac,
            label: "Acutal Cost",
            color: '#f0522e'
        }, {
            // Earned Value       
            data: data.ev,
            label: "Earned Value",
            color: '#8cc63f'
        }];

        var options = {
            grid:    { show: false,
            color: "rgb(48, 48, 48)",
            tickColor: "rgba(255, 255, 255, 0)",
            backgroundColor: "rgb(255, 255, 255)" }
        };

        // Lines
        $.plot(chartHtmlElement, graphData, {
            series: {
                points: {
                    show: false
                },
                lines: {
                    show: true,
                    fill: false
                },
                shadowSize: 0
            },
            grid: {
                color: '#bfbfbf',
                borderColor: { bottom: "#bfbfbf", left: "#bfbfbf" },
                borderWidth: 1,
                hoverable: true
            },
            xaxis: {
                mode: "time", 
                timeformat: "%d %b %Y", 
                minTickSize: [1, "day"]
            },
            yaxis: {
                axisLabel: 'Hours',
                axisLabelUseCanvas: true,
                axisLabelFontSizePixels: 12,
                axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
                axisLabelPadding: 5
            }
        });
    }


    //Draws the gauge for spi or cpi.
    //value should be between 0.0 and 2.0.
    //placeholder is the html element id to draw. (gauge.js)
    function drawGauge(value, placeholder){

        var opts= {
          lines: 12, // The number of lines to draw
          angle: 0, // The length of each line
          lineWidth: 0.60, // The line thickness
          pointer: {
            length: 0.65, // The radius of the inner circle
            strokeWidth: 0.05, // The rotation offset
            color: '#424242' // Fill color
        },
        limitMax: 'true',   // If true, the pointer will not go past the end of the gauge
        percentColors: [[0.0, "#ff0000" ], [0.40, "#a9d70b" ], [0.60, "#a9d70b" ], [1.0, "#ff0000"]],
        strokeColor: '#E0E0E0',   // to see which ones work best for you
        generateGradient: true
        };

        var target = document.getElementById(placeholder); // your canvas element
        var gauge = new Gauge(target).setOptions(opts); // create sexy gauge!
        //gauge.setTextField(document.getElementById("spi"));
        gauge.maxValue = 2000; // set max gauge value
        gauge.animationSpeed = 32; // set animation speed (32 is default value)
        gauge.set(value); // set actual value
    }