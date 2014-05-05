class BaselinesController < ApplicationController
  unloadable

  helper :baselines

  model_object Baseline

  before_filter :find_model_object, :except => [:new, :create, :current_baseline]
  before_filter :find_project_from_association, :except => [:new, :create, :current_baseline]
  before_filter :find_project_by_project_id, :only => [:new, :create, :current_baseline]
  before_filter :authorize

  def show
    @baseline = Baseline.find(params[:id])
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
    baseline_id = @project.baselines.where(state: 'current').first.id
    redirect_to baseline_path(baseline_id)
  end

end