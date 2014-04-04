class DeleteJoinTables< ActiveRecord::Migration

  def up
    drop_table :baseline_versions_baselines
    drop_table :baseline_issues_baselines
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end