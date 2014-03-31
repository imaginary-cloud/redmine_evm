class AddStartDateToBaselines < ActiveRecord::Migration
  def change
    add_column :baselines, :start_date, :date
  end
end