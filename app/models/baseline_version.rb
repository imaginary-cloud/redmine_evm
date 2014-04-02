class BaselineVersion < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :baselines 
  has_many :baseline_issues


  #TODO: This method is not being used right now.
  def create_version(baseline, version)
    baseline_version = BaselineVersion.new original_version_id: version.id, effective_date: version.effective_date, start_date: version.created_on
    baseline_version.save
    baseline.baseline_versions << baseline_version
  end
end