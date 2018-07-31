class Admin::ProductsController < ApplicationController

  def index
    @selected_left_navi_link = "products_feed"
    @community = @current_community
  end

  def import
      dir = Rails.root.join('public', 'uploads')
      Dir.mkdir(dir) unless Dir.exist?(dir)
      File.open(dir.join(params[:file].original_filename), 'wb') do |file|
        file.write(params[:file].read)
      end
      file_name = params[:file].original_filename
      @community = @current_community
      Delayed::Job.enqueue(ListingImageJob.new(@community.id,file_name), priority: 2)
      redirect_to admin_community_products_path 
  end
end
