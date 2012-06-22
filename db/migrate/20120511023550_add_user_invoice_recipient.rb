class AddUserInvoiceRecipient < ActiveRecord::Migration
  def up
    add_column :users, :invoice_recipient, :string, :default => 'N/A'
  end

  def down
    remove_column :users, :invoice_recipient
  end
end
