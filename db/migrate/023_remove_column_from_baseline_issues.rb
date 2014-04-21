class RemoveColumnFromBaselineIssues < ActiveRecord::Migration
  def change
    remove_column :baseline_issues, :time_week
  end
end

