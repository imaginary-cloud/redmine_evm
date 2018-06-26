class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.float :rate
      t.integer :user_id
    end
  end
end