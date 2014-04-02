class BaselinesController < ApplicationController
  unloadable

  model_object Baseline

  before_filter :find_model_object, :except => [:index, :new, :create]
  before_filter :find_project_from_association, :except => [:index, :new, :create]
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
    #TODO: Change the last baseline made to closed. This means that the last one is not the current baseline.
    #@last_baseline_made = Baseline.last
    #@last_baseline_made.state = 'Closed'
    #@last_baseline_made.save

    @baseline = Baseline.new(params[:baseline])
    @baseline.project = @project
    @baseline.state = 'Open'


    if @baseline.save

      #TODO: Make all this logic to model.
      #Copy versions from current project to this new baseline.
      @versions = @project.versions
      create_version(@baseline, @versions)
      @versions.each do |version|
        #baseline_version = BaselineVersion.create( original_version_id: version.id, effective_date: version.effective_date, start_date: version.created_on )
        #@baseline.baseline_versions << baseline_version
      end

      #Copy issues from the current project to this new baseline.
      @issues = @project.issues
      @issues.each do |issue|
        baseline_issue = BaselineIssue.create( original_issue_id: issue.id, estimated_time: issue.estimated_hours, due_date: issue.due_date, time_week: issue.start_date.strftime('%U').to_i, baseline_version_id: issue.fixed_version_id )
        @baseline.baseline_issues << baseline_issue
      end

      flash[:notice] = l(:notice_successful_create)
      redirect_to settings_project_path(@project, :tab => 'baselines')
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
    #TODO: If we destroy our current baseline, then the last one will be current.
    #if @baseline.first?
    #  @last_baseline_made = Baseline.last
    #  @last_baseline_made.status = 'Open'
    #end

     @baseline.destroy
     redirect_to settings_project_path(@project, :tab => 'baselines')
  end
end
