class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :login, :null => false
      t.string :password, :null => false
      t.string :role, :length => 16, :default => 'user', :null => false
      t.string :name, :null => false
      t.string :email, :null => false
      t.string :address, :null => false

      t.timestamps
    end

    # NOTE: log in, create a new admin, and delete this admin RIGHT AWAY.
    User.create(:login => 'admin',
                :password => 'CHANGE_ME_NOW',
                :role => 'admin',
                :name => 'Temporary Administrator',
                :email => 'nobody@example.com',
                :address => 'xyzzy')

    # Default user. All existing work entries will be assigned to this user.
    u = User.create(:login => 'first_user',
                    :password => 'CHANGE_ME_NOW',
                    :role => 'user',
                    :name => 'First User',
                    :email => 'first_user@example.com',
                    :address => 'xyzzy')

    add_column :work_entries, :user_id, :integer, :null => false, :default => u.id
  end

  def down
    remove_column :work_entries, :user_id
    drop_table :users
  end
    
end
