class ChangeOzValuesToBeDecimalInListingVariants < ActiveRecord::Migration
  def change
  	change_column :listing_variants, :oz_value, :decimal, precision: 5, scale: 2
  end
end
