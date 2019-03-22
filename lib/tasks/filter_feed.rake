require 'csv'
namespace :listing do
  desc "Populate the filter data"
  task :filter_feed => :environment do
    list=ListingVariant.to_csv
  	# CSV.foreach("#{Rails.root}/tmp/filter/test1.csv",encoding: "iso-8859-1:UTF-8", headers: true)  do |row|
   #    @listing = Listing.where(title: row["Keywords"]).first
   #    if @listing.present?
   #  	  if row["Manufacturer"].present?
   #  	    @manu = Manufacturer.find_or_create_by(name: row["Manufacturer"])
   #      end
   #      if row["Color"].present?
   #        @color = ListingColor.find_or_create_by(name: row["Color"])
   #      end
   #      if row["ParentSKU"] == row["ChildSKU"]
   #        @parent_id = nil
   #      else
   #        @parent_id = row["ParentSKU"]
   #      end
   #    	if row["Size"].present? 
   #        extra_small = ["xs","mini","x-small","xx-small","itty bitty","pettie","mini","extrasmall"]
   #        small = ["s","small","baby"]
   #        medium = ["m", "med","medium","standard","regular","intermediate"]
   #        large = ["l","lg","jumbo","large","souper","super","wolf","heavy"]
   #        extra_large = ["xl","x-lg","x-large","xxl","xx-lg","xx-large","colossal","giant","king","extra-heavy"]            
   #        @val =  row["Size"].split(", ")
   #        if @val.count.eql?(1)
   #          @val = !!row["Size"].match(/[a-z]\//) ? row["Size"].split(/[a-z]\//) : !!row["Size"].match(/[\(\)]/) ? row["Size"].split(/[\(\)]/) : @val
   #        end
   #        @val.each do |size_val|
   #          @size_value = extra_small.include?(size_val.delete(" ").downcase) ? "extra_small" : small.include?(size_val.delete(" ").downcase) ? "small" : medium.include?(size_val.delete(" ").downcase) ? "medium" : large.include?(size_val.delete(" ").downcase) ? "large" : extra_large.include?(size_val.delete(" ").downcase) ? "extra_large" : nil
   #          check_syn = ["-","x","for","with","gallon"]
   #          if check_syn.any?{|v| v.exclude?(size_val)} && !@size_value.present?
   #            if size_val.include?("/")
   #              value = size_val.split
   #              if value.size.eql?(3)
   #                size_val = "#{value.first.to_f + ((value.second).to_r).to_f}" + value.last
   #              elsif value.size.eql?(2)
   #                size_val = "#{((value.first).to_r).to_f}" + value.last
   #              end
   #            end
   #            @inches = size_val.downcase.include?("inch") ? size_val.to_f : nil
   #            @oz = size_val.downcase.include?("oz") ? size_val.to_f : nil
   #            @lbs = size_val.downcase.include?("lb") ? size_val.to_f : nil
   #          end
   #          @mixed_value = size_val.include?("x") ? size_val : nil
   #          @list = ListingVariant.where(sku_name: row["ChildSKU"]).first
   #          if @list.present?
   #            if @size_value.present?
   #              @list.update_attributes(size_name: @size_value)
   #            elsif @inches.present?
   #              @list.update_attributes(inches_value: @inches)
   #            elsif @oz.present?
   #              @list.update_attributes(oz_value: @oz)
   #            elsif @lbs.present?
   #              @list.update_attributes(lbs_value: @lbs)
   #            end
   #          else
   #            @listing_variant = ListingVariant.new(parent_sku: @parent_id, sku_name: row["ChildSKU"], listing_id: @listing.id, size_name: @size_value, mixed_value: @mixed_value, original_value: row["Size"], manufacturer_id: @manu.id, listing_color_id: @color.try(:id), inches_value: @inches, oz_value: @oz, lbs_value: @lbs, in_stock: row["Instock"])
   #            @listing_variant.save!
   #          end  
   #        end
   #      else
   #        @size_value = nil
   #        @inches = nil
   #        @oz = nil
   #        @lbs = nil
   #        @mixed_value = nil
   #        @listing_variant = ListingVariant.new(parent_sku: @parent_id, sku_name: row["ChildSKU"], listing_id: @listing.id, size_name: @size_value, mixed_value: @mixed_value, original_value: row["Size"], manufacturer_id: @manu.id, listing_color_id: @color.try(:id), inches_value: @inches, oz_value: @oz, lbs_value: @lbs, in_stock: row["Instock"])
   #        @listing_variant.save!  
   #    	end
   #    end	
    #end
  end
end