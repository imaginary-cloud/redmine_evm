class BaselinesController < ApplicationController
  unloadable

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create]
  before_filter :find_project_from_association, :except => [:new, :create]
  before_filter :find_project_with_project_id, :only => [:new, :create]
  before_filter :authorize

  def show 
    project_evm_data = [@baseline.planned_value_by_week, @project.actual_cost_by_week, @project.earned_value_by_week(@baseline.id)]
    versions_evm_data = []
    evm_data = []

    baseline_versions = @baseline.baseline_versions 
    project_versions = @project.versions            

    project_versions.each do |version|
      version_evm_data = []
      baseline_version = baseline_versions.where(original_version_id: version.id).first

      baseline_version.nil? ? 0 : version_evm_data.push(baseline_version.planned_value_by_week)
      
      version_evm_data = [version.actual_cost_by_week, version.earned_value_by_week(@baseline.id)]
      versions_evm_data.push(version_evm_data)
    end
    evm_data = [project_evm_data,versions_evm_data].to_json
  end

  def new
    @baseline = Baseline.new
  end

  def create
    @baseline = Baseline.new(params[:baseline])
    @baseline.project = @project
    @baseline.state = l(:label_current_baseline)
    @baseline.start_date = @project.get_start_date

    if @baseline.save

      @baseline.create_versions(@project.versions)
      @baseline.create_issues(@project.issues)
      flash[:notice] = l(:notice_successful_create)
      redirect_to settings_project_path(@project, :tab => 'baselines')
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if request.put? && params[:baseline]
      attributes = params[:baseline].dup
      @baseline.safe_attributes = attributes
      if @baseline.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to settings_project_path(@project, :tab => 'baselines')
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @baseline.destroy
    redirect_to settings_project_path(@project, :tab => 'baselines')
  end

  private 

  def find_project_with_project_id
    @project = Project.find(params[:project_id])
  end
end