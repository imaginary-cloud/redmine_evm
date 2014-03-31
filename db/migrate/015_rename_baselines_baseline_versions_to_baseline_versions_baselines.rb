class RenameBaselinesBaselineVersionsToBaselineVersionsBaselines < ActiveRecord::Migration
  def change
    rename_table :baselines_baseline_versions, :baseline_versions_baselines
  end
end