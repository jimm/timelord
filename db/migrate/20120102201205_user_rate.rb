class UserRate < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :rate_type, :length => 8, :null => false, :default => 'hourly'
      t.integer :rate_amount_cents, :null => false, :default => 0
    end
  end

  def down
    remove_columns :users, :rate_amount_cents, :rate_type
  end
end
