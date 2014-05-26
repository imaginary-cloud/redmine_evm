class RemoveColumnsFromBaselineIssues < ActiveRecord::Migration
  def up
    remove_column :baseline_issues, :subject
    remove_column :baseline_issues, :description
    remove_column :baseline_issues, :tracker_id
    remove_column :baseline_issues, :start_date
  end
  def down
    add_column :baseline_issues, :subject, :string
    add_column :baseline_issues, :description, :string
    add_column :baseline_issues, :tracker_id, :integer
    add_column :baseline_issues, :start_date, :date
  end
end

