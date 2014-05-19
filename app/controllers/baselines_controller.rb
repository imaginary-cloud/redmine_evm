class BaselinesController < ApplicationController
  unloadable

  helper :baselines
  include BaselinesHelper

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create, :current_baseline]
  before_filter :find_project_from_association, :except => [:new, :create, :current_baseline]
  before_filter :find_project_by_project_id, :only => [:new, :create, :current_baseline]
  before_filter :authorize

  def show
    @baseline = Baseline.find(params[:id])    
    @project_chart_data  = [convert_to_chart(@baseline.planned_value_by_week),
                            convert_to_chart(@project.actual_cost_by_week), 
                            convert_to_chart(@project.earned_value_by_week(@baseline.id))]

    @forecast_is_enabled = params[:forecast]
    if(@forecast_is_enabled)
      #Forecasts line and top lines  
      num_of_work_weeks = @baseline.estimate_at_completion_duration.abs.floor
      eac_forecast_line = [[ Time.now.beginning_of_week, @baseline.actual_cost ], [ num_of_work_weeks.week.from_now.beginning_of_week, @baseline.estimate_at_completion_cost ]] #The estimated line after actual cost
      start_date = @project.get_start_date.beginning_of_week
      if(@baseline.end_date.beginning_of_week < Date.today.beginning_of_week) #This if is for old projects
        end_date = [@project.end_date.beginning_of_week, @baseline.end_date.beginning_of_week].max
      else
        end_date = [@project.end_date.beginning_of_week, @baseline.end_date.beginning_of_week, num_of_work_weeks.week.from_now].max 
      end
      bac_top_line = [[start_date, @baseline.budget_at_completion],[end_date, @baseline.budget_at_completion]] 
      eac_top_line = [[start_date, @baseline.estimate_at_completion_cost],[end_date, @baseline.estimate_at_completion_cost]]

      @project_chart_data << convert_to_chart(eac_forecast_line)
      @project_chart_data << convert_to_chart(bac_top_line)
      @project_chart_data << convert_to_chart(eac_top_line)
    end
  end

  def new
    @baseline = Baseline.new

    if @project.issues.empty?
      flash[:error] = "Define a issue first"
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end
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

  def current_baseline
    if @project.baselines.any?
      baseline_id = @project.baselines.last.id
      redirect_to baseline_path(baseline_id)
    else 
      flash[:error] = l(:error_no_baseline)
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end
  end

end