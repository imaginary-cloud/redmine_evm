class DeleteJoinTables< ActiveRecord::Migration

  def up
    drop_table :baseline_versions_baselines
    drop_table :baseline_issues_baselines
  end

  def down
    create_table :baseline_issues_baselines, :id => false do |t|
      t.integer :baseline_id
      t.integer :baseline_issue_id
    end
    create_table :baseline_versions_baselines, :id => false do |t|
      t.integer :baseline_id
      t.integer :baseline_version_id
    end
  end

end