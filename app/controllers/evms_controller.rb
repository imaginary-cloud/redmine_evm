class EvmsController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:id])
    @baselines = @project.baselines
  end

end
