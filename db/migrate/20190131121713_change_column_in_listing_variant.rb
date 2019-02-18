class ChangeColumnInListingVariant < ActiveRecord::Migration
  def change
  	rename_column :listing_variants, :parent_id, :listing_child_id
  end
end
