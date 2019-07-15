# == Schema Information
#
# Table name: listing_variants
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  parent_sku       :string(255)
#  sku_name         :string(255)
#  listing_id       :integer
#  size_name        :string(255)
#  mixed_value      :string(255)
#  manufacturer_id  :integer
#  listing_color_id :integer
#  original_value   :string(255)
#  inches_value     :float(24)
#  oz_value         :float(24)
#  lbs_value        :float(24)
#  in_stock         :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  listing_child_id :integer
#  other_value      :float(24)
#  unit_name        :string(255)
#  title            :string(255)
#  style_value      :string(255)
#

class ListingVariant < ActiveRecord::Base
  belongs_to :manufacturer
  belongs_to :listing_color
  belongs_to :listing
    
  enum size: [:extra_small, :small, :medium, :large, :extra_large]
  enum inches: {"0-6 inches": :'1-6', "13-18 inches": :'13-18', "19-24 inches": :'19-24', "25-36 inches": :'25-36', "37-48 inches": :'37-48', "Over 48 inches": :'48-72'}
  enum weight: {"0-1 oz.": :"0.1-1 oz", "1-8 oz.": :"0-8 oz", "9-16 oz.": :"9-16 oz", "1-6 lbs.": :"1-6", "7-15 lbs.": :"7-15", "16-30 lbs.": :"16-30", "31-40 lbs.": :"31-40", "40+ lbs.": :"40-100"}

  EXTRA_SMALL = ["xs","mini","x-small","xx-small","itty bitty","pettie","mini"].freeze
  SMALL = ["s","small","baby"].freeze
  MEDIUM = ["m", "med","medium","standard","regular","intermediate"].freeze
  LARGE = ["l","lg","jumbo","large","souper","super","wolf","heavy"].freeze
  EXTRA_LARGE = ["xl","x-lg","x-large","xxl","xx-lg","xx-large","colossal","giant","king","extra-heavy"].freeze          

  #validates_numericality_of :oz_value, :only_integer => true, :message => "Value must be numeric", :allow_nil => true

  def self.to_csv(options = {})
    CSV.foreach("#{Rails.root}/tmp/filter/test_full.csv",encoding: "iso-8859-1:UTF-8", headers: true)  do |row|
      @listing = Listing.where(title: row["Keywords"]).first
      if @listing.present?
        if row["Manufacturer"].present?
          @manu = ListingVariant.manufacturer_create(row["Manufacturer"])
        end 
        @color = row["Color"].present? ? ListingVariant.listing_clr_creation(row["Color"]) : nil     
        @parent_sku = row["ParentSKU"].eql?(row["ChildSKU"]) ? nil : row["ParentSKU"]         
        @title = @parent_sku.present? ? nil : row["Name"]
        #@listing_child_id = @parent_sku.present? ? ListingVariant.where(sku_name: row["ParentSKU"]).first.try(:id) : nil
        @listing_id = @parent_sku.present? ? ListingVariant.where(sku_name: row["ParentSKU"]).first.try(:listing_id) : @listing.id
        if row["Size"].present?
          @val =  row["Size"].split(", ")
          if @val.count.eql?(1)
            @val = !!row["Size"].match(/[a-z]\//) ? row["Size"].split(/[a-z]\//) : !!row["Size"].match(/[\(\)]/) ? row["Size"].split(/[\(\)]/) : @val
          end
          @val.each do |size_val|
            @size_value = ListingVariant.get_size_name(size_val.delete(" ").downcase)
            check_syn = ["-","x","for","with","gallon"]
            if size_val.exclude?("-") && size_val.exclude?("x")              
              length_width_val(size_val.downcase)
              @inches = @inches_value
              @oz   = @oz_value
              @lbs = @lbs_value     
            end
            @mixed_value = mixed_values(row["Size"])
            @list = ListingVariant.where(sku_name: row["ChildSKU"]).first
            if @list.present?
              if @size_value.present?
                @list.update_attributes(size_name: @size_value)
              elsif @inch.present?
                @list.update_attributes(inches_value: @inch)
              elsif @oz.present?
                @list.update_attributes(oz_value: @oz)
              elsif @lbs.present?
                @list.update_attributes(lbs_value: @lbs)
              end
            else
              @listing_variant = ListingVariant.new(parent_sku: @parent_sku, sku_name: row["ChildSKU"], listing_child_id: @listing.id, listing_id: @listing_id, size_name: @size_value, mixed_value: @mixed_value, original_value: row["Size"], manufacturer_id: @manu.id, listing_color_id: @color.try(:id), inches_value: @inches, oz_value: @oz, lbs_value: @lbs, in_stock: row["InStock"], title: @title, style_value: row["Style"])
              @listing_variant.save
            end
          end
        else
          set_val_nil
          @size_val = nil
          @listing_variant = ListingVariant.new(parent_sku: @parent_sku, sku_name: row["ChildSKU"], listing_child_id: @listing.id, listing_id: @listing_id, size_name: @size_value, mixed_value: @mixed_value, original_value: row["Size"], manufacturer_id: @manu.id, listing_color_id: @color.try(:id), inches_value: @inches, oz_value: @oz, lbs_value: @lbs, in_stock: row["InStock"], title: @title, style_value: row["Style"])
          @listing_variant.save
        end
      end
    end        
  end

  def self.manufacturer_create(manu)
    Manufacturer.find_or_create_by(name: manu)
  end
  def self.listing_clr_creation(color)
    ListingColor.find_or_create_by(name: color)
  end

  def self.get_size_name(name)
    EXTRA_SMALL.include?(name) ? "extra_small" : SMALL.include?(name) ? "small" : MEDIUM.include?(name) ? "medium" : LARGE.include?(name) ? "large" : EXTRA_LARGE.include?(name) ? "extra_large" : nil   
  end

  def self.mixed_values(value)
    value.include?("x") ? value : nil
  end

  def self.length_width_val(size_val)
    if size_val.include?("/")
      value = size_val.split
      if value.size.eql?(3)
        size_val = "#{value.first.to_f + ((value.second).to_r).to_f}" + value.last
      elsif value.size.eql?(2)
        size_val = "#{((value.first).to_r).to_f}" + value.last
      end
    end
    @inches_value = size_val.include?("inch") ? size_val.to_f : nil
    @oz_value = size_val.include?("oz") ? size_val.to_f : nil
    @lbs_value = size_val.include?("lb") ? size_val.to_f : nil
  end

  def self.set_val_nil
    @inches = nil
    @oz = nil
    @lbs = nil
  end
end
