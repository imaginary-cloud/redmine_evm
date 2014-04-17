class EvmsController < ApplicationController
  unloadable

  respond_to :html, :json, :js

  def index
    @project = Project.find(params[:project_id])
    @baselines = @project.baselines.order( 'created_on DESC' ) #Order to get the current baseline first.
    respond_with(@baselines)
  end

end
