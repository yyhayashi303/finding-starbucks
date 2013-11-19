class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name
      t.string :address
      t.decimal :lng
      t.decimal :lat

      t.timestamps
    end
  end
end
