class AddUpdateHoursToBaselines < ActiveRecord::Migration
  def up
    add_column :baselines, :update_hours, :boolean, :default => false
  end

  def down
    remove_column :baselines, :update_hours
  end
end