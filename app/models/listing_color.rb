# == Schema Information
#
# Table name: listing_colors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListingColor < ActiveRecord::Base
	has_many :listing_variants
end
