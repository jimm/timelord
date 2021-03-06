class CreateWorkEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :work_entries do |t|
      t.integer :code_id
      t.date :worked_at
      t.integer :minutes
      t.integer :rate_cents
      t.integer :fee_cents
      t.text :note
      t.timestamps null: false
    end
  end
end
