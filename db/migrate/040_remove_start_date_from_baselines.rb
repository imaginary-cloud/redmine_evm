class RemoveStartDateFromBaselines < ActiveRecord::Migration
  def up
    remove_column :baselines, :start_date
  end

  def down
    add_column :baselines, :start_date, :date
  end
end