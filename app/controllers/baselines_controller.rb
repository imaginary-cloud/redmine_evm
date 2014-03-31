class BaselinesController < ApplicationController
  unloadable

  model_object Baseline

  #before_filter :find_project_by_project_id, :only => [:update, :edit]
  before_filter :find_model_object, :except => [:index, :new, :create]
  before_filter :find_project_from_association, :except => [:index, :new, :create]

  
  def index
    @project = Project.find(params[:project_id])
  	@baselines = @project.baselines.all
  end

  def show
    @baseline = Baseline.find(params[:id])
  end

  def new

  end

  def create 
    
  end 

  def edit
  end

  def update
    if request.put? && params[:baseline]
      attributes = params[:baseline].dup
      @baseline.safe_attributes = attributes
      if @baseline.save
        respond_to do |format|
          format.html {
            flash[:notice] = l(:notice_successful_update)
            redirect_to settings_project_path(@project, :tab => 'baselines')
          }
          #format.api  { render_api_ok }
        end
      else
        respond_to do |format|
          format.html { render :action => 'edit' }
          format.api  { render_validation_errors(@version) }
        end
      end
    end
  end

  def destroy
     
  end

end
