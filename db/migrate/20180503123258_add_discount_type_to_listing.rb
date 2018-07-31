class AddDiscountTypeToListing < ActiveRecord::Migration
  def change
    add_column :listings, :weekly_discount, :integer
    add_column :listings, :bi_weekly_discount, :integer
    add_column :listings, :monthly_discount, :integer
    add_column :listings, :quarterly_discount, :integer
  end
end
