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
                                                   start_date: version.start_date || version.created_on, name: version.name, description: version.description, status: version.status)
        baseline_versions << baseline_version
      end
    end
  end

  def create_issues issues
    unless issues.nil?
      issues.each do |issue|
        baseline_issue = BaselineIssue.create(original_issue_id: issue.id, estimated_time: issue.estimated_hours || 0, due_date: issue.due_date,
                                              done_ratio: issue.done_ratio, subject: issue.subject, description: issue.description, tracker_id: issue.tracker_id,start_date: issue.start_date)

        baseline_version = self.baseline_versions.find_by_original_version_id(issue.fixed_version_id)
        
        unless baseline_version.nil?
          baseline_issue.baseline_version_id = baseline_version.id
        end
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
