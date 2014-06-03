class RemoveColumnStatusDescriptionFromBaselineVersions < ActiveRecord::Migration
  def up
    remove_column :baseline_versions, :description
    remove_column :baseline_versions, :status
  end
  def down
    add_column :baseline_versions, :description, :string
    add_column :baseline_versions, :status, :string
  end
end