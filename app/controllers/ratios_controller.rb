class RatiosController < ApplicationController
	unloadable
	include IndicatorsLogic

	helper :ratios
	include RatiosHelper

	def index
		@project = Project.find(params[:id])
		data = IndicatorsLogic::retrive_data(@project)
		@evms = []
		@evms << {
					:name => @project.name,
					:indicators => IndicatorsLogic::calc_indicators(@project, data[0], data[1])
				}
		@project.versions.where(:status=>"open").each do |my_version|
			data = IndicatorsLogic::retrive_data(my_version)
			@evms << {
					:name => my_version.name,
					:indicators => IndicatorsLogic::calc_indicators(my_version, data[0], data[1])
				}
		end
		respond_to do |format|
			format.html { render :action => 'index' }
			format.csv {
				send_data(evm_csv(@evms), :type => 'text/csv; header=present', :filename => 'evm.csv')
			}
		end
	end
end
