class Baseline < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable

  belongs_to :project
  has_many :baseline_issues, dependent: :destroy_all
  has_many :baseline_versions, dependent: :destroy_all 

  validates :name, :presence => true

  before_destroy :remove_baseline_issues 

  safe_attributes 'name',
  'description',
  'due_date'

  def create_version versions
    versions.each do |version|
      baseline_version = BaselineVersion.create( original_version_id: version.id, effective_date: version.effective_date, start_date: version.created_on)
      self.baseline_versions << baseline_version
    end
  end

  def create_issues issues
    issues.each do |issue|
      bv = self.baseline_versions.where("original_version_id = :id", id: issue.fixed_version_id).first  
      baseline_issue = BaselineIssue.create(original_issue_id: issue.id, estimated_time: issue.estimated_hours, due_date: issue.due_date, baseline_version_id: bv.id, time_week: issue.start_date)
      baseline_issues << baseline_issue
    end
  end
end
