class BaselinesController < ApplicationController
  unloadable

  def index
  	@project = Project.find(params[:id])
  	@baselines = @project.baselines.all
  end

  def show
  end

  def new
  end

  def update
  end

  def destroy
  end

end
