class ChangeEstimatedHoursTypeInBaselineIssues < ActiveRecord::Migration
  def up
    change_column :baseline_issues, :estimated_time, :float
  end

  def down
    change_column :baseline_issues, :estimated_time, :integer
  end
end

