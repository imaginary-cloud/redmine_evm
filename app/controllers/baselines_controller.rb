class BaselinesController < ApplicationController

  helper :baselines

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create, :index]
  before_filter :find_project_from_association, :except => [:new, :create, :index]
  before_filter :find_project_by_project_id, :only => [:new, :create, :index]
  before_filter :authorize

  def index
    if @project.baselines.any?
      baseline_id = @project.baselines.last.id
      redirect_to baseline_path(baseline_id)
    else 
      flash[:error] = l(:error_no_baseline)
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end
  end

  def show
    @baselines = @project.baselines.order('created_on DESC')
    @forecast_is_enabled = params[:forecast]

    if(@project.has_time_entries_with_no_issue)
      flash[:warning] = l(:warning_log_time_with_no_issue)
    end
  end

  def new
    @baseline = Baseline.new

    if @project.issues.empty?
      flash[:error] = l(:error_no_issues)
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end
  end

  def create
    @baseline = Baseline.new(params[:baseline])
    @baseline.project = @project
    @baseline.update_hours = true if params[:update_estimated_hours] == "1"

    if @baseline.save
      versions_to_exclude = @baseline.versions_to_exclude params[:operator_target_versions], params[:selected_target_versions]
      @baseline.create_versions @project.versions, versions_to_exclude, params[:update_estimated_hours]                                
      @baseline.create_issues @project.issues, params[:update_estimated_hours]

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

end