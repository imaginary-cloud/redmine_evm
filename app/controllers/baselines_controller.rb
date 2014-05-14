class BaselinesController < ApplicationController
  unloadable

  helper :baselines
  include BaselinesHelper

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create, :current_baseline, :forecasts]
  before_filter :find_project_from_association, :except => [:new, :create, :current_baseline, :forecasts]
  before_filter :find_project_by_project_id, :only => [:new, :create, :current_baseline, :forecasts]
  before_filter :authorize

  def show
    @baseline = Baseline.find(params[:id])
    @planned_value = @baseline.planned_value
    @actual_cost   = @project.actual_cost
    @earned_value  = @project.earned_value(@baseline.id)
    @spi = @earned_value / @planned_value #Schedule Performance Index
    @cpi = @earned_value / @actual_cost   #Cost Performance Index
    @schedule_variance = @earned_value - @planned_value
    @cost_variance = @earned_value - @actual_cost
    @bac = @baseline.planned_value_at_completion  #Budget at completion
    @eac = @bac / @cpi                    #Estimate at completion, can use other formulas! (bac / cpi has no notion of schedule)
    @etc = @eac - @actual_cost            #Estimate at completion
    @vac = @bac - @eac                    #Variance at completion
    @completed_actual = @actual_cost / @eac
    @planned_weeks = @baseline.planned_value_by_week

    @project_chart_data  = [convert_to_chart(@planned_weeks),
                            convert_to_chart(@project.actual_cost_by_week), 
                            convert_to_chart(@project.earned_value_by_week(@baseline.id))]

                         
    #From now on is forecast information:
    @forecast_chart_data = Array.new(@project_chart_data) #Copy project data array  

    @planned_duration = @planned_weeks.count
    @actual_duration = @planned_weeks.select { |key,value| key <= Date.today }.count
    #Method using Earned Duration (ED) from http://www.pmknowledgecenter.com/dynamic_scheduling/control/earned-value-management-forecasting-time
    #(max(PD, AT) - ED) and ED is earned duration can get by ED = AT * SPI
    @earned_duration = @actual_duration * @spi
    @eac_duration = ( [@planned_duration, @actual_duration].max ) - @earned_duration

    #Forecasts line and top lines    
    num_of_work_weeks = @eac_duration.abs.floor
    eac_forecast_line = [[ Time.now.beginning_of_week, @actual_cost ], [ num_of_work_weeks.week.from_now.beginning_of_week, @eac ]] #The estimated line after actual cost
    start_date = @project.get_start_date.beginning_of_week
    end_date = [@project.end_date.beginning_of_week, @baseline.end_date.beginning_of_week, num_of_work_weeks.week.from_now].max 
    bac_top_line = [[start_date, @bac],[end_date, @bac]] 
    eac_top_line = [[start_date, @eac],[end_date, @eac]]

    @forecast_chart_data << convert_to_chart(eac_forecast_line)
    @forecast_chart_data << convert_to_chart(bac_top_line)
    @forecast_chart_data << convert_to_chart(eac_top_line)
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

  def current_baseline
    if @project.baselines.any?
      baseline_id = @project.baselines.where(state: 'current').first.id
      redirect_to baseline_path(baseline_id)
    else 
      flash[:error] = l(:error_no_baseline)
      redirect_to settings_project_path(@project, :tab => 'baselines')
    end
  end

  def forecasts
    puts "Estou aqui!"
    puts params 
    render :partial => 'common/preview'
    #Render da partial
  end

end