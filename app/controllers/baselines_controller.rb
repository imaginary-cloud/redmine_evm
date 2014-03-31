class BaselinesController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :only => [:index, :new, :create]

  def index
  	@baselines = @project.baselines.all
  end

  def show
    @baseline = Baseline.find(params[:id])
  end

  def new
    @baseline = Baseline.new
  end

  def create
    @baseline = Baseline.new(params[:baseline])
    @baseline.project = @project

    if @baseline.save
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end

  end 

  def update

  end

  def destroy
     
  end


end
