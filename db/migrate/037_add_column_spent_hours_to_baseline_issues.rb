class AddColumnSpentHoursToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :spent_hours, :float
  end

  def down
    remove_column :baseline_issues, :spent_hours
  end
end