class RatiosController < ApplicationController
  unloadable
  include IndicatorsLogic

  helper :ratios
  include RatiosHelper

  def index
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html do
        @evms = []
        data = IndicatorsLogic::retrive_data(@project)
        @evms << evm(@project)
        @project.versions.where(:status=>"open").each do |my_version|
          data = IndicatorsLogic::retrive_data(my_version)
          evm_hash = evm(my_version)
          evm_hash[:version] = my_version
          @evms << evm_hash
        end
        render :action => 'index'
      end
      format.csv do
        if params[:version].present?
          ver = @project.versions.find(params[:version])
          evm_hash = evm(ver)
          csv_fn = "evm-project-#{@project.id}-version-#{ver.id}.csv"
        else
          evm_hash = evm(@project)
          csv_fn = "evm-project-#{@project.id}.csv"
        end
        send_data(evm_csv(evm_hash), :type => 'text/csv; header=present', :filename => csv_fn)
      end
    end
  end

private

  def evm(proj_or_ver)
    data = IndicatorsLogic::retrive_data(proj_or_ver)
    { :name => proj_or_ver.name,
      :indicators => IndicatorsLogic::calc_indicators(proj_or_ver, data[0], data[1]) }
  end
end
