class RatiosController < ApplicationController
  	unloadable
	include IndicatorsLogic

  def index
  
  	@project = Project.find(params[:id])
  	@proj_or_vers_data = IndicatorsLogic::retrive_data(@project)
	@proj_or_vers_indicators = IndicatorsLogic::calc_indicators(@project, @proj_or_vers_data[0], @proj_or_vers_data[1])
		
  end

 
end



