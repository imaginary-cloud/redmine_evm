class RemoveColumnFromBaselineIssues < ActiveRecord::Migration
  def up
    remove_column :baseline_issues, :time_week
  end
  def down
    add_column :baseline_issues, :time_week, :integer
  end
end

