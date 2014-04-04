class AddColumnsToBaselineIssues < ActiveRecord::Migration
  def change
    add_column :baseline_issues, :done_ratio, :integer
    add_column :baseline_issues, :start_date, :date
    add_column :baseline_issues, :subject, :string
    add_column :baseline_issues, :description, :string
    add_column :baseline_issues, :tracker_id, :integer
  end
end