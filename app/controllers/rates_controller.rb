class RatesController < ApplicationController
  model_object Rate

  before_filter :find_model_object, :except => [:new, :create, :index]
  before_filter :find_project_from_association, :except => [:new, :create, :index]
  before_filter :find_project_by_project_id, :only => [:new, :create, :index]
  before_filter :authorize

  def index
    # if @project.baselines.any?
    #   baseline_id = @project.baselines.last.id
    #   redirect_to baseline_path(baseline_id)
    # else 
    #   flash[:error] = l(:error_no_baseline)
    #   redirect_to settings_project_path(@project, :tab => 'baselines')
    # end
  end

  def show
    # @baselines = @project.baselines.order('created_on DESC')
    # @forecast_is_enabled = params[:forecast]

    # if(@project.has_time_entries_with_no_issue)
    #   flash[:warning] = l(:warning_log_time_with_no_issue)
    # end
  end

  def new
    @project_user_rates = Rate.where(project_id: @project.id).collect { |rate| rate.user_id }
    @rate = Rate.new
    if @project.users.empty?
      flash[:error] = l(:error_no_users)
      redirect_to settings_project_path(@project, :tab => 'rates')
    end
  end

  def create
    params[:rates].select { |rate| !rate[:rate].blank? }.each do |rate|
      @rate = Rate.create(rate_params(rate))
      @rate.project = @project
      @rate.user = User.find(rate[:user_id])
      render action: 'edit' unless @rate.save
    end
    flash[:notice] = l(:notice_successful_create)
    redirect_to settings_project_path(@project, :tab => 'rates')
  end

  def edit
  end

  def update
    if request.patch? && params[:rate]
      @rate.update_attributes!(rate_params(params[:rate]))
      if @rate.save
        flash[:notice] = l(:notice_successful_update)
        redirect_to settings_project_path(@project, :tab => 'rates')
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @rate.destroy
    redirect_to settings_project_path(@project, :tab => 'rates')
  end

  private

  def rate_params rate
    rate.permit(:rate)
  end
end