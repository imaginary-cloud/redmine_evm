class DropTableBaselineExclusions < ActiveRecord::Migration
  def up
    drop_table :baseline_exclusions
  end
  def down
    create_table :baseline_exclusions do |t|
      t.integer :baseline_id
      t.integer :version_id
    end
  end
end