class AddIsClosedToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :is_closed, :boolean, :default => false
  end

  def down
    remove_column :baseline_issues, :is_closed
  end
end