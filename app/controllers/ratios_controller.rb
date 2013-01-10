class RatiosController < ApplicationController
	unloadable
	include IndicatorsLogic

	helper :ratios
	include RatiosHelper

	def index
		@project = Project.find(params[:id])
		@evms = []
		data = IndicatorsLogic::retrive_data(@project)
		@evms << evm(@project)
		@project.versions.where(:status=>"open").each do |my_version|
			data = IndicatorsLogic::retrive_data(my_version)
			@evms << evm(my_version)
		end
		respond_to do |format|
			format.html { render :action => 'index' }
			format.csv {
				send_data(evm_csv(@evms), :type => 'text/csv; header=present', :filename => 'evm.csv')
			}
		end
	end

private

	def evm(proj_or_ver)
		data = IndicatorsLogic::retrive_data(proj_or_ver)
		{ :name => proj_or_ver.name,
			:indicators => IndicatorsLogic::calc_indicators(proj_or_ver, data[0], data[1]) }
	end
end
