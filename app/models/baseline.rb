class Baseline < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Schedulable
  unloadable

  belongs_to :project
  has_many :baseline_issues, dependent: :destroy
  has_many :baseline_versions, dependent: :destroy

  validates :name, :due_date, :presence => true
  validates :due_date, :date => true
  validate :due_date_check, on: :create


  before_create {update_baseline_status("#{l(:label_old_baseline)}", self.project_id)}
  after_destroy {update_baseline_status("#{l(:label_current_baseline)}", self.project_id)}

  acts_as_customizable

  safe_attributes 'name',
  'description',
  'due_date'

  def create_version versions
    unless versions.nil?
      versions.each do |version|
        baseline_version = BaselineVersion.create( original_version_id: version.id, effective_date: version.effective_date,
                                                   start_date: version.created_on, name: version.name, description: version.description, status: version.status)
        self.baseline_versions << baseline_version
      end
    end
  end

  def create_issues issues
    unless issues.nil?
      issues.each do |issue|
        baseline_issue = BaselineIssue.create(original_issue_id: issue.id, estimated_time: issue.estimated_hours, due_date: issue.due_date,
                                              done_ratio: issue.done_ratio, subject: issue.subject, description: issue.description, tracker_id: issue.tracker_id)
        unless issue.due_date.nil?
          baseline_issue.time_week = issue.due_date.strftime('%U')
        end
        baseline_version = self.baseline_versions.where("original_version_id = :id", id: issue.fixed_version_id).first
        unless baseline_version.nil?
          baseline_issue.baseline_version_id = baseline_version.id
        end
        baseline_issues << baseline_issue
      end
    end
  end

  def update_baseline_status status, project_id
    if project_id
      project = Project.find(project_id) 
      baseline = project.baselines.last 
    else
      baseline = Baseline.last 
    end
    if baseline 
      baseline.state = status 
      baseline.save
    end
  end

  def start_date 
    Project.find(project_id).created_on
  end

  def end_date
    due_date
  end

  # Validation - Check if due_date is after baseline is defined.
  def due_date_check
    unless due_date.nil?
      if due_date < Date.today
        errors.add(:due_date, l(:error_due_date_invalid))
      end
    end
  end

end
