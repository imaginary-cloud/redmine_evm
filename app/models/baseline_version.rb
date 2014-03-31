class BaselineVersion < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :baselines 
  has_many :baseline_issues


  def create version
    baseline_version = BaselineVersion.new original_version_id: version.id effective_date: version.effective_date start_date: version.created_om
    baseline_version.save
  end
end