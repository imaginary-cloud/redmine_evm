class BaselinesController < ApplicationController
  unloadable

  def index
  	@project = Project.find(params[:id])
  	@baselines = @project.baselines.all
  end

  def show
    @baseline = Baseline.find(params[:id])
  end

  def new

  end

  def create 
    
  end 

  def update

  end

  def destroy
    
  end

end
