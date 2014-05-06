class RenameBaselineIssuesColumn < ActiveRecord::Migration
  def up
    rename_column :baseline_issues, :estimated_time, :estimated_hours
  end

  def down
    rename_column :baseline_issues, :estimated_hours, :estimated_time
  end
end

