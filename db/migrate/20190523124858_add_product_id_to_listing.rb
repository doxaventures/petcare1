class AddProductIdToListing < ActiveRecord::Migration
  def change
    add_column :listings, :product_id, :string
  end
end
