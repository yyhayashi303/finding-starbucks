class Stores < ActiveRecord::Migration
  def change
	  rename_column :stores, :sotreId, :store_id
  end
end
