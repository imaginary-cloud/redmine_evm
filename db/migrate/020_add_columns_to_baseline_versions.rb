class AddColumnsToBaselineVersions < ActiveRecord::Migration
  def change
    add_column :baseline_versions, :name, :string
    add_column :baseline_versions, :description, :string
    add_column :baseline_versions, :status, :string
  end
end