class CreateListingVariants < ActiveRecord::Migration
  def change
    create_table :listing_variants do |t|
	  t.string :name
      t.string :parent_sku
      t.string :sku_name
	  t.integer :listing_id
	  t.string :size_name
	  t.string :mixed_value
      t.integer :manufacturer_id
	  t.integer :listing_color_id
	  t.string :original_value
	  t.float :inches_value
	  t.float :oz_value
	  t.float :lbs_value
	  t.string :in_stock     	
      t.timestamps null: false
    end
  end
end
