class AddColumnBaselineIdToBaselineIssues < ActiveRecord::Migration
  def change
    add_column :baseline_issues, :baseline_id, :integer
    add_index :baseline_issues, :baseline_id
  end
end