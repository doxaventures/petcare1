class ChangeLbsValuesToBeDecimalInListingVariants < ActiveRecord::Migration
  def change
  	change_column :listing_variants, :lbs_value, :decimal, precision: 5, scale: 2
  	change_column :listing_variants, :inches_value, :decimal, precision: 6, scale: 2
  end
end
