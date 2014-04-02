class DeleteJoinTables< ActiveRecord::Migration
 
  def change
    drop_table :baseline_versions_baselines
    drop_table :baseline_issues_baselines
  end
end