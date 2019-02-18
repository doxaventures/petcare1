class AddParentIdToListingVariant < ActiveRecord::Migration
  def change
    add_column :listing_variants, :parent_id, :integer
    add_column :listing_variants, :other_value, :float
    add_column :listing_variants, :unit_name, :string
  end
end
