class AddColumnExcludeToBaselineVersion < ActiveRecord::Migration
def change
    add_column :baseline_versions, :exclude, :boolean
  end
end