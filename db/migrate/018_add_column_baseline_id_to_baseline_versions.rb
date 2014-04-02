class AddColumnBaselineIdToBaselineVersions < ActiveRecord::Migration
  def change
    add_column :baseline_versions, :baseline_id, :integer
    add_index :baseline_versions, :baseline_id
  end
end