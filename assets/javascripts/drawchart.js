/* Dependencies: jquery, flot, flottime, flotlabel, gaugemin */

//Draws the chart for the project or versions. (Flot)
function drawChart(dataToChart, placeholder, actualWeek){ 
    var actualWeek = actualWeek
    var chartHtmlElement = $('#' + placeholder);
    var data = dataToChart;

    var eacLine;
    
    var startDate = data[0][0][0];
    var endDate;   
    var plannedEndDate  = data[0][data[0].length-1][0];
    var earnedEndDate   = data[2][data[2].length-1][0];

    if (plannedEndDate > earnedEndDate)
        endDate = plannedEndDate;
    else endDate = earnedEndDate;

    if (actualWeek < endDate) { 
        var markings = [{ color: "#E0E0E0", lineWidth: 1, xaxis: { from: actualWeek , to: actualWeek } }]; //This is the marker to the "Project is here" marking today date.
        eacLine = data[3];
    }

    var graphData = [{
        data: eacLine ,
        label:"Estimate at Complete",
        color: "#FCB040", dashes: { show: true, lineWidth: 3 }
    },{ 
        data: data[4],
        label:"Budget at Complete Top Line", 
        color: "#CEE8FA", dashes: { show: true, lineWidth: 1 }
    },{ 
        data: data[5] ,
        label: "Estimated at Complete Top Line",
        color: "#FFE2B8", dashes: { show: true, lineWidth: 1 }       
    },{
        data: data[0],
        label: "Planned Value",
        color: '#0F75BC'
    },{ 
        data: data[1],
        label: "Acutal Cost",
        color: '#FBC040'
    },{  
        data: data[2],
        label: "Earned Value",
        color: '#8CC63F'
    }];


    // Lines
    var plot = $.plot(chartHtmlElement, graphData, {
        series: {
            points: { show: false },
            shadowSize: 0,
            lines: { lineWidth: 3 }
        },
        grid: {
          markings: markings,
          color: 'transparent',
          borderColor: { bottom: "#BFBFBF", left: "#BFBFBF" },
          borderWidth: 1,
          hoverable: true
        },
        xaxis: {
            mode: "time", 
            timeformat: "%d %b %Y", /*"%d %b %Y"*/
            minTickSize: [1, "day"],
            axisLabel: 'Date',
            axisLabelUseCanvas: true,
            axisLabelFontSizePixels: 10,
            axisLabelPadding: 6
        },
        yaxis: {
            axisLabel: 'Hours',
            axisLabelUseCanvas: true,
            axisLabelFontSizePixels: 10,
            axisLabelPadding: 6
        },
        legend: { show: false }
    });


    //The marker 'project is here'.
    if (actualWeek < endDate) {
        var maxYValue = parseInt($('.flot-y-axis .tickLabel').last().text());
        var o = plot.pointOffset({ x: actualWeek, y: maxYValue * 0.1}); // TODO y

        chartHtmlElement.append("<div id='marker-label-chart' class='markers' style='left:" + (o.left + 5) + "px;top:" + o.top + "px;'>Project is here</div>");
        
    }

}
