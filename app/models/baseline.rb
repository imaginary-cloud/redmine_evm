class Baseline < ActiveRecord::Base
	include Redmine::SafeAttributes
	unloadable

	belongs_to :project
	has_and_belongs_to_many :baseline_issues
	has_and_belongs_to_many :baseline_versions

	validates :name, :presence => true

	before_destroy { remove_baseline_issues }

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
			baseline_issue = BaselineIssue.create(original_issue_id: issue.id, estimated_time: issue.estimated_hours, due_date: issue.due_date, baseline_version_id: bv.id, time_week: issue.star_date)
			self.baseline_issues << baseline_issue
		end
	end

  #TODO: This method removes issues that are not associated with any baseline. Not working.
  def remove_baseline_issues
  	removed_baseline_issues = baseline_issues
  	baseline_issues.clear
  	removed_baseline_issues.each do |bi|
  		if bi.baselines.empty?
  			bi.destroy
  		end
  	end
  end

end
