class RenameBaselinesBaselineIssuesToBaselineIssuesBaselines < ActiveRecord::Migration
  def change
    rename_table :baselines_baseline_issues, :baseline_issues_baselines
  end
end