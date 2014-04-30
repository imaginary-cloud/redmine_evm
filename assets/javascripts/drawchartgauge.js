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
        color: '#fcb040'
    }, {
        // Earned Value       
        data: data.ev,
        label: "Earned Value",
        color: '#8cc63f'
    }];

    var options = {
        grid:    { 
            show: false,
            color: "rgb(48, 48, 48)",
            tickColor: "rgba(255, 255, 255, 0)",
            backgroundColor: "rgb(255, 255, 255)",
        }
    };

    // Lines
    $.plot(chartHtmlElement, graphData, {
        series: {
            points: {
                show: false
            },
            lines: {
                show: true,
                fill: false, 
                lineWidth: 3
            },
            shadowSize: 0
        },
        grid: {
            color: 'transparent',
            borderColor: { bottom: "#bfbfbf", left: "#bfbfbf" },
            borderWidth: 1,
            hoverable: true
        },
        xaxis: {
            mode: "time", 
            timeformat: "%d %b", /*"%d %b %Y"*/
            minTickSize: [1, "day"]
        },
        yaxis: {
            axisLabel: 'Hours',
            axisLabelUseCanvas: true,
            axisLabelFontSizePixels: 10,
            axisLabelPadding: 6

        },
        legend: {
            show: false
        }
    });

    //Remove the 0 in the y axis.
    $('.flot-y-axis .tickLabel').first().html("");

}