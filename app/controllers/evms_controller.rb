class EvmsController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :only => [:index, :chart_data, :versions_chart_data, :evm_variables]
  before_filter :authorize

  def index
    #Loads the current baseline from baselines.
    redirect_to baseline_path(@project.baselines.where(state: 'current').first.id)
  end

end