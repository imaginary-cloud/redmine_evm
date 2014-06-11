class AddStatusToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :status, :string
  end

  def down
    remove_column :baseline_issues, :status
  end
end