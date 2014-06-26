class AddColumnUpdateHoursToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :update_hours, :boolean
  end

  def down
    remove_column :baseline_issues, :update_hours
  end
end
