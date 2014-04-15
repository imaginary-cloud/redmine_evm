class EvmsController < ApplicationController
  unloadable

  respond_to :html, :json, :js

  def index
    @project = Project.find(params[:project_id])
    @baselines = @project.baselines.all
    respond_with(@baselines)
  end

end
