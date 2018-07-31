class AddListingPriceCentsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :listing_price_cents, :integer
  end
end
