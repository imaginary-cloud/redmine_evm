class Baseline < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Schedulable
  unloadable

  belongs_to :project
  has_many :baseline_issues, dependent: :destroy
  has_many :baseline_versions, dependent: :destroy

  validates :name, :due_date, :presence => true


  before_create {update_baseline_status("#{l(:label_old_baseline)}", project_id)}
  after_destroy {update_baseline_status("#{l(:label_current_baseline)}", project_id)}

  acts_as_customizable

  safe_attributes 'name',
  'description',
  'due_date'

  def create_versions versions
    unless versions.nil?
      versions.each do |version|
        baseline_version = BaselineVersion.create( original_version_id: version.id, effective_date: version.end_date,
                                                   start_date: version.get_start_date, name: version.name, description: version.description, status: version.status)
        baseline_versions << baseline_version
      end
    end
  end

  def create_issues issues
    unless issues.nil?
      issues.each do |issue|
        baseline_issue = BaselineIssue.new(original_issue_id: issue.id, done_ratio: issue.done_ratio)

        baseline_version = self.baseline_versions.find_by_original_version_id(issue.fixed_version_id)
        unless baseline_version.nil?
          baseline_issue.baseline_version_id = baseline_version.id
        end

        if(Project.find(project_id).baselines.count > 1)
          if(issue.done_ratio == 100 || issue.status.name == "Rejected")
            baseline_issue.estimated_hours = issue.total_spent_hours
            puts issue.due_date
            puts issue.time_entries.maximum('spent_on')
            issue.due_date.nil? ? baseline_issue.due_date = issue.time_entries.maximum('spent_on') : baseline_issue.due_date = issue.due_date
          else
            baseline_issue.estimated_hours = issue.estimated_hours || 0
            issue.due_date.nil? ? baseline_issue.due_date = issue.time_entries.maximum('spent_on') : baseline_issue.due_date = issue.due_date
          end
        else
          baseline_issue.estimated_hours = issue.estimated_hours || 0
          issue.due_date.nil? ? baseline_issue.due_date = issue.time_entries.maximum('spent_on') : baseline_issue.due_date = issue.due_date
        end 
        baseline_issue.save
        baseline_issues << baseline_issue
      end
    end
  end

  def update_baseline_status status, project_id
      project = Project.find(project_id) 
      baseline = project.baselines.last 

    if baseline 
      baseline.state = status 
      baseline.save
    end
  end

  def end_date
    due_date
  end

  #Earned Value (EV)
  def earned_value
    project = Project.find(project_id)
    project.earned_value(self.id)
  end

  #Actual Cost (AC)
  def actual_cost
    project = Project.find(project_id)
    project.actual_cost
  end

  #Schedule Performance Index (SPI)
  def schedule_performance_index
    if self.planned_value != 0
      earned_value / self.planned_value
    else
      return 0
    end
  end

  #Cost Performance Index (CPI)
  def cost_performance_index
    if actual_cost != 0
      earned_value / actual_cost
    else
      return 0
    end
  end

  #Schedule Variance (SV)
  def schedule_variance
    earned_value - planned_value
  end

  #Cost Variance (CV)
  def cost_variance
    earned_value - project.actual_cost
  end

  #Budget at Completion (BAC)
  def budget_at_completion
    planned_value_at_completion
  end

  #Estimate at Completion (EAC$) Yaxis
  def estimate_at_completion_cost
    if cost_performance_index == 0 #when there is still no earned_value, done_ratio
      budget_at_completion
    else
      budget_at_completion / cost_performance_index
    end
  end

  #Estimate to complete (ETC)
  def estimate_to_complete
    estimate_at_completion_cost - actual_cost
  end

  #Variance at Completion (VAC)
  def variance_at_completion
    budget_at_completion - estimate_at_completion_cost
  end

  # % Completed
  def completed_actual
    actual_cost / estimate_at_completion_cost
  end

  #Planned Duration (PD)
  def planned_duration
    planned_value_by_week.count
  end

  #Actual duration (AT)
  def actual_duration
    planned_value_by_week.select { |key,value| key <= Date.today }.count
  end

  #Earned Duration (ED)
  def earned_duration
    actual_duration * schedule_performance_index
  end

  #Estimate at Completion Duration (EACt)
  #Method using Earned Duration (ED) from http://www.pmknowledgecenter.com/dynamic_scheduling/control/earned-value-management-forecasting-time
  #(max(PD, AT) - ED) and ED is earned duration can get by ED = AT * SPI
  def estimate_at_completion_duration
    ( [planned_duration, actual_duration].max ) - earned_duration
  end

end
