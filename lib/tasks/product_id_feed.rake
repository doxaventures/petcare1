require 'csv'
namespace :add_product_id do
  desc "Populate the product id"
  task :product_id_feed => :environment do
    CSV.foreach("#{Rails.root}/tmp/filter/product_id.csv",:col_sep=>'|', :quote_char => '|', headers: true)  do |row|
      @listing = Listing.where(title: row["title"]).first
      if @listing.present?
      	@listing.update_attributes(product_id: row["id"])
      end
    end
   end
end