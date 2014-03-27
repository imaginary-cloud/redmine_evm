class AddBaselineVersionIdToBaselineIssues < ActiveRecord::Migration
  def change
    add_column :baseline_issues, :baseline_version_id, :integer
  end
end