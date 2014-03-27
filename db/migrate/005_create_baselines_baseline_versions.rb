class CreateBaselinesBaselineVersions < ActiveRecord::Migration
  def change
    create_table :baselines_baseline_versions, :id => false do |t|
      t.integer :baseline_id
      t.integer :baseline_version_id
    end
  end
end