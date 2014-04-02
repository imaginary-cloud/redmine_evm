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

  def def_stuff
    self.baseline_issues
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
