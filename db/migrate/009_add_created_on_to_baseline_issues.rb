class AddCreatedOnToBaselineIssues < ActiveRecord::Migration
  def change
    add_column :baseline_issues, :created_on, :timestamp
  end
end