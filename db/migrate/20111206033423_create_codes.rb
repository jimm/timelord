class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.integer :location_id
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
