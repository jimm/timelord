class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :login, :null => false
      t.string :hashed_password, :null => false
      t.string :role, :length => 16, :default => 'user', :null => false
      t.string :name, :null => false
      t.string :email, :null => false
      t.string :address, :null => false

      t.timestamps
    end
  end
end
