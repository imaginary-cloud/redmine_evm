function drawIndicators(plannedValue, actualCost, earnedValue){
  var plannedValue = plannedValue;
  var actualCost   = actualCost;
  var earnedValue  = earnedValue;
  
  //Bar indicators and behavior from sidebar.---------------------------------------------------------------------------
  var maxValue = Math.max(plannedValue, actualCost, earnedValue);
  var barMaxHeight = 100;

  var spiPlannedValueBarHeight = Math.round((plannedValue * barMaxHeight) / maxValue);
  var earnedValueBarHeight     = Math.round((earnedValue  * barMaxHeight) / maxValue);
  var cpiActualCostBarHeight   = Math.round((actualCost   * barMaxHeight) / maxValue);

  $('#spi-pv-bar').height(spiPlannedValueBarHeight);
  $('#spi-ev-bar').height(earnedValueBarHeight);
  $('#cpi-ev-bar').height(earnedValueBarHeight);
  $('#cpi-ac-bar').height(cpiActualCostBarHeight);

  var minHeightForFont = parseInt($('.bars p').css("font-size"));
   
  //This aligns the Label inside the bars correctly when these its too small.
  if(spiPlannedValueBarHeight < minHeightForFont)
    $('#evm-spi-pv-bar-container p').css("padding-bottom", "" + spiPlannedValueBarHeight + "px");
  else $('#evm-spi-pv-bar-container p').css("line-height", "" + spiPlannedValueBarHeight + "px"); //Alinha o "PV" no bar
  if(earnedValueBarHeight < minHeightForFont){
    $('#evm-spi-ev-bar-container p').css("padding-bottom", "" + earnedValueBarHeight     + "px");
    $('#evm-cpi-ev-bar-container p').css("padding-bottom", "" + earnedValueBarHeight     + "px");
  } else {
    $('#evm-spi-ev-bar-container p').css("line-height", "" + earnedValueBarHeight     + "px");
    $('#evm-cpi-ev-bar-container p').css("line-height", "" + earnedValueBarHeight     + "px");
  }
  if(cpiActualCostBarHeight < minHeightForFont)
    $('#evm-cpi-ac-bar-container p').css("padding-bottom", "" + cpiActualCostBarHeight   + "px");
  else $('#evm-cpi-ac-bar-container p').css("line-height", "" + cpiActualCostBarHeight   + "px");
}