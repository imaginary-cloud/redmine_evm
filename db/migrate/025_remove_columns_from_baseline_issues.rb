class RemoveColumnsFromBaselineIssues < ActiveRecord::Migration
  def up
    remove_column :baseline_issues, :subject
    remove_column :baseline_issues, :description
    remove_column :baseline_issues, :tracker_id
    remove_column :baseline_issues, :start_date
  end

  def down
    add_column :baseline_issues, :subject
    add_column :baseline_issues, :description
    add_column :baseline_issues, :tracker_id
    add_column :baseline_issues, :start_date
  end
end

