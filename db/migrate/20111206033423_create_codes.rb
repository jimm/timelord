class CreateCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :codes do |t|
      t.integer :location_id
      t.string :code
      t.string :name
      t.timestamps null: false
    end
  end
end
