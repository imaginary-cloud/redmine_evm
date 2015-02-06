/* Dependencies: jquery, flot, flottime, flotlabel, gaugemin */

//Draws the chart for the project or versions. (Flot)
function drawChart(dataToChart, placeholder, actualWeek, endDate){ 
    var actualWeek = actualWeek;
    var chartHtmlElement = $('#' + placeholder);
    var data = dataToChart;
    var endDate = endDate;

    var actualCostEstimateLine;
    var earnedValueEstimateLine;

    if (actualWeek <= endDate) { //For OLD Projects
        var markings = [{ color: "#E0E0E0", lineWidth: 1, xaxis: { from: actualWeek , to: actualWeek } }]; //This is the marker to the "Project is here" marking today date.
        actualCostEstimateLine = data.actual_cost_forecast;
        earnedValueEstimateLine = data.earned_value_forecast;
    }

    var graphData = [
    { 
        data: data.bac_top_line,
        label: RedmineEVM.I18n.t('budget_at_complete'),
        color: "#CEE8FA", dashes: { show: true, lineWidth: 1 }
    },{ 
        data: data.eac_top_line ,
        label: RedmineEVM.I18n.t('estimated_at_complete'),
        color: "#FFE2B8", dashes: { show: true, lineWidth: 1 }     
    },{
        data: actualCostEstimateLine ,
        label: RedmineEVM.I18n.t('actual_cost_forecast'),
        color: "#FCB040", dashes: { show: true, lineWidth: 3 }, points: { show: true, fill: true, fillColor: "#FCB040" }
    },{ 
        data: earnedValueEstimateLine ,
        label: RedmineEVM.I18n.t('earned_value_forecast'),
        color: "#8CC63F", dashes: { show: true, lineWidth: 3 }, points: { show: true, fill: true, fillColor: "#8CC63F" }       
    },{
        data: data.planned_value,
        label: RedmineEVM.I18n.t('planned_value'),
        color: '#0F75BC'
    },{ 
        data: data.actual_cost,
        label: RedmineEVM.I18n.t('actual_cost'),
        color: '#FBC040'
    },{  
        data: data.earned_value,
        label: RedmineEVM.I18n.t('earned_value'),
        color: '#8CC63F'
    }];


    // Lines
    var plot = $.plot(chartHtmlElement, graphData, {
        series: {
            shadowSize: 0,
            lines: { lineWidth: 3 },
            points: { radius: 2 }
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
            axisLabel: RedmineEVM.I18n.t('label_date'),
            axisLabelUseCanvas: true,
            axisLabelFontSizePixels: 10,
            axisLabelPadding: 6
        },
        yaxis: {
            min: 0,
            axisLabel: RedmineEVM.I18n.t('label_hours'),
            axisLabelUseCanvas: true,
            axisLabelFontSizePixels: 10,
            axisLabelPadding: 6
        },
        legend: { show: false }
    });

    //Flot tooltip style
    $("<div id='tooltip'></div>").css({
            position: "absolute",
            display: "none",
            //border: "1px solid #fdd",
            padding: "2px",
            "background-color": "#FFFFFF",
            opacity: 0.80
        }).appendTo("body");

    //Flot tooltip
    chartHtmlElement.bind("plothover", function (event, pos, item) {

        if (item) {
            var x = item.datapoint[0].toFixed(2),
                y = item.datapoint[1].toFixed(2);

            var hours = y
            var date = moment(parseInt(x)).format("DD MMM YYYY")

            //Use moment.js lib!
            $("#tooltip").html("<b>" + item.series.label + "</b> " + hours + " hours <br>" + date) 
                .css({top: item.pageY+5, left: item.pageX+5})
                .fadeIn(200);
        } else {
            $("#tooltip").hide();
        }
    });

    //The marker 'project is here'.
    if (actualWeek <= endDate) {
        var maxYValue = parseInt($('.flot-y-axis .tickLabel').last().text());
        var o = plot.pointOffset({ x: actualWeek, y: maxYValue * 0.1});
        chartHtmlElement.append("<div id='marker-label-chart' class='markers' style='left:" + (o.left + 5) + "px;top:" + o.top + "px;'>Project is here</div>");
    }
}
