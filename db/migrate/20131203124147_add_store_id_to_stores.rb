class AddStoreIdToStores < ActiveRecord::Migration
  def change
    add_column :stores, :sotreId, :Integer
    add_index :stores, :sotreId
  end
end
