class AddCreatedOnToBaselineVersions < ActiveRecord::Migration
  def change
    add_column :baseline_versions, :created_on, :timestamp
  end
end