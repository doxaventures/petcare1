class AddListingTitleToListingVariant < ActiveRecord::Migration
  def change
    add_column :listing_variants, :title, :string
    add_column :listing_variants, :style_value, :string
  end
end
