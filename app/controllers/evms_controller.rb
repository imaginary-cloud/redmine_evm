class EvmsController < ApplicationController
  unloadable

  respond_to :html, :json

  def index
    @project = Project.find(params[:id])
    @baselines = @project.baselines
    respond_with(@baselines)
  end

end
