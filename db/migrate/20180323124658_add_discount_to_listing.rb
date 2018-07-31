class AddDiscountToListing < ActiveRecord::Migration
  def change
    add_column :listings, :discount, :integer
    add_column :listings, :recurring_payment, :text
  end
end
