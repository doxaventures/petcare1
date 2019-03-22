namespace :listing_color do
  desc "Populate the listing color data"
  task :color_feed => :environment do
  	ListingColor.find_or_create_by(name: "Beige")
	ListingColor.find_or_create_by(name: "Black")
	ListingColor.find_or_create_by(name: "Blue")
	ListingColor.find_or_create_by(name: "Bronze")
	ListingColor.find_or_create_by(name: "Brown")
	ListingColor.find_or_create_by(name: "Clear")
	ListingColor.find_or_create_by(name: "Copper")
	ListingColor.find_or_create_by(name: "Gold")
	ListingColor.find_or_create_by(name: "Gray")
	ListingColor.find_or_create_by(name: "Green")
	ListingColor.find_or_create_by(name: "Multicolor")
	ListingColor.find_or_create_by(name: "Orange")
	ListingColor.find_or_create_by(name: "Pink")
	ListingColor.find_or_create_by(name: "Purple")
	ListingColor.find_or_create_by(name: "Red")
	ListingColor.find_or_create_by(name: "Silver")
	ListingColor.find_or_create_by(name: "White")
	ListingColor.find_or_create_by(name: "Yellow")
  end
end