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
        if(Project.find(project_id).baselines.count >1)
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

end
