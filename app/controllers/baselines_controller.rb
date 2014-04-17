class BaselinesController < ApplicationController
  unloadable

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create]
  before_filter :find_project_from_association, :except => [:new, :create]
  before_filter :find_project_by_project_id, :only => [:new, :create]

  def show
  end

  def chart_data
    @project = Project.find(params[:project_id])
    @baseline = Baseline.find(params[:id])
    
    planned_value_by_week = @baseline.planned_value_by_week
    planned_value_by_week_converted = Hash[planned_value_by_week.map{ |k, v| [k.to_time.to_i * 1000, v] }]

    actual_cost_by_week = @project.actual_cost_by_week
    actual_cost_by_week_converted = Hash[actual_cost_by_week.map{ |k, v| [k.to_time.to_i * 1000, v] }] 

    earned_value_by_week = @project.earned_value_by_week
    earned_value_by_week_converted = Hash[earned_value_by_week.map{ |k, v| [k.to_time.to_i * 1000, v] }]

    data_to_chart = Hash.new
    data_to_chart['pv'] = planned_value_by_week_converted.to_a
    data_to_chart['ac'] = actual_cost_by_week_converted.to_a
    data_to_chart['ev'] = earned_value_by_week_converted.to_a

    respond_to do |format|
      format.json { render :json => data_to_chart }
    end

  end

  def new
    @baseline = Baseline.new
  end

  def create
    @baseline = Baseline.new(params[:baseline])
    @baseline.project = @project
    @baseline.state = l(:label_current_baseline)
    @baseline.start_date = @project.start_date || @project.created_on.to_date

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
end
