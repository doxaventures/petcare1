module ListingIndexService::Search

  class SphinxAdapter < SearchEngineAdapter

    # http://pat.github.io/thinking-sphinx/advanced_config.html
    SPHINX_MAX_MATCHES = 1000

    INCLUDE_MAP = {
      listing_images: :listing_images,
      listing_variants: :listing_variants,
      author: :author,
      num_of_reviews: {author: :received_testimonials},
      location: :location
    }

    def search(community_id:, search:, includes:)
      included_models = includes.map { |m| INCLUDE_MAP[m] }

      # rename listing_shape_ids to singular so that Sphinx understands it
      search = HashUtils.rename_keys({:listing_shape_ids => :listing_shape_id}, search)

      if DatabaseSearchHelper.needs_db_query?(search) && DatabaseSearchHelper.needs_search?(search)
        return Result::Error.new(ArgumentError.new("Both DB query and search engine would be needed to fulfill the search"))
      end

      if DatabaseSearchHelper.needs_search?(search)
        if search_out_of_bounds?(search[:per_page], search[:page])
          DatabaseSearchHelper.success_result(0, [], includes)
        else
          search_with_sphinx(community_id: community_id,
                             search: search,
                             included_models: included_models,
                             includes: includes)
        end
      else
        DatabaseSearchHelper.fetch_from_db(community_id: community_id,
                                           search: search,
                                           included_models: included_models,
                                           includes: includes)
      end
    end

    private

    def search_with_sphinx(community_id:, search:, included_models:, includes:)
      get_listing_ids = []
      numeric_search_fields = search[:fields].select { |f| f[:type] == :numeric_range }
      perform_numeric_search = numeric_search_fields.present?
      numeric_search_match_listing_ids =
        if numeric_search_fields.present?
          numeric_search_params = numeric_search_fields.map { |n|
            { custom_field_id: n[:id], numeric_value: n[:value] }
          }
          NumericFieldValue.search_many(numeric_search_params).collect(&:listing_id)
        else
          []
        end
      
      conditions = {}
      if search[:weight].present?
        if search[:weight].include?("oz")
          get_value = search[:weight].delete(" oz")
          values = get_value.split('-')
          oz_values = (values.first.to_f..values.last.to_f).step(0.1).map{|f| f.round(2)}      
          conditions.merge!(:oz_value => oz_values)
        else
          values = search[:weight].split('-')
          lb_values = search[:weight].include?("40+ lbs.") ? (40.to_f..90.to_f).step(0.1).map{|f| f.round(2)} : (values.first.to_f..values.last.to_f).step(0.1).map{|f| f.round(2)}
          conditions.merge!(:lbs_value => lb_values)
        end
      end

      if search[:length].present?
        values = search[:length].split('-')
        length_values = (values.first.to_f..values.last.to_f).step(0.1).map{|f| f.round(2)}
        conditions.merge!(:inches_value => length_values)
      end

      if search[:variants].present?
        values = search[:variants].map{|x| x.to_i}
        conditions.merge!(:manufacturer_id => values)        
      end

      if search[:color_ids].present?
        values = search[:color_ids].map{|x| x.to_i}
        conditions.merge!(:listing_color_id => values)
      end
      
      if search[:size].present?
        conditions.merge!(:size_name => search[:size])
      end
      
      if conditions.present?
        query = conditions.keys.map{|field| "#{field} IN (:#{field})" }.join(" AND ")
        query_params = conditions.symbolize_keys
        get_list_ids = ListingVariant.where(query, query_params).collect(&:listing_id).flatten.compact
        listing_ids = get_list_ids.present? ? get_list_ids : [999999999]
      else
        get_listing_ids = ListingVariant.where("parent_sku IS NULL").pluck(:listing_id).uniq
        child_ids = ListingVariant.where("parent_sku IS NOT NULL").pluck(:listing_child_id)
        total_listing_ids = Listing.where("id NOT IN (?)",child_ids).pluck(:id)
        listing_ids = (total_listing_ids | get_listing_ids).flatten.compact.uniq
      end

      if perform_numeric_search && numeric_search_match_listing_ids.empty?
        # No matches found with the numeric search
        # Do a short circuit and return emtpy paginated collection of listings wrapped into a success result
        DatabaseSearchHelper.success_result(0, [], nil)
      else
        with = HashUtils.compact(
          {
            community_id: community_id,
            category_id: search[:categories], # array of accepted ids
            listing_shape_id: search[:listing_shape_id],
            price_cents: search[:price_cents],
            #listing_id: numeric_search_match_listing_ids - get_listing_ids
            listing_id: listing_ids
          })

        # if search[:location_name].present?
        #   limit = 10_000
        #   if (search[:lat].present? && search[:lat] > 0) && (search[:lng].present? && search[:lng] > 0)
        #     @coordinates = [to_radians(search[:lat]), to_radians(search[:lng])]
        #     # @coordinates = [search[:lat], search[:lng]]
        #   else
        #     latlng = Geocoder.coordinates(search[:location_name])
        #     @coordinates = [to_radians(latlng[0]), to_radians(latlng[1])] if latlng.present?
        #     # @coordinates = [latlng[0], latlng[1]] if latlng.present?
        #   end
        #   # with_geo = HashUtils.compact(
        #   #   {
        #   #     community_id: community_id,
        #   #     category_id: search[:categories], # array of accepted ids
        #   #     listing_shape_id: search[:listing_shape_id],
        #   #     price_cents: search[:price_cents],
        #   #     listing_id: numeric_search_match_listing_ids,
        #   #     geodist: 0.0..limit.to_f,
        #   #   })
        #   with = with.merge({geodist: 0.0..limit.to_f}) if @coordinates.present?
        # end


        # date_range = nil
        # if search[:date].present?
        #   date = search[:date].split("/")
        #   fortmat_date = [date[1], date[0], date[2]].join("/").to_datetime
        # else
        #   fortmat_date = Time.now
        # end
        # date_range = (fortmat_date - 5.years)..fortmat_date
          # with = HashUtils.compact(
          #   {
          #     community_id: community_id,
          #     category_id: search[:categories], # array of accepted ids
          #     listing_shape_id: search[:listing_shape_id],
          #     price_cents: search[:price_cents],
          #     listing_id: numeric_search_match_listing_ids,
          #     created_at: date_range,
          #   })
        # if search[:length].present?
        #   values = search[:length].split('-')
        #   with =  with.merge({inches_value: values.first.to_f..values.last.to_f})
        # end

        # if date_range
        #   with = with.merge({created_at: date_range})
        # end

        selection_groups = search[:fields].select { |v| v[:type] == :selection_group }
        grouped_by_operator = selection_groups.group_by { |v| v[:operator] }

        with_all = {
          custom_dropdown_field_options: (grouped_by_operator[:or] || []).map { |v| v[:value] },
          custom_checkbox_field_options: (grouped_by_operator[:and] || []).flat_map { |v| v[:value] },
        }

        search_filter = {
          sql: {
            include: included_models
          },
          page: search[:page],
          per_page: search[:per_page],
          star: true,
          with: with,
          with_all: with_all,
          order: "#{@coordinates.present? ? 'geodist ASC, sort_date DESC' : 'sort_date DESC'}",
          max_query_time: 1000 # Timeout and fail after 1s
        }

        # if @coordinates.present?
        #   search_filter = search_filter.merge({geo: @coordinates})
        # end

        # if @coordinates.present?
        #   search_filter = {
        #     sql: {
        #       include: included_models
        #     },
        #     geo: @coordinates,
        #     page: search[:page],
        #     per_page: search[:per_page],
        #     star: true,
        #     with: with_geo,
        #     with_all: with_all,
        #     order: 'geodist ASC',
        #     max_query_time: 1000 # Timeout and fail after 1s
        #   }
        # else
        #   search_filter = {
        #     sql: {
        #       include: included_models
        #     },
        #     page: search[:page],
        #     per_page: search[:per_page],
        #     star: true,
        #     with: with,
        #     with_all: with_all,
        #     order: 'sort_date DESC',
        #     max_query_time: 1000 # Timeout and fail after 1s
        #   }
        # end

        models = Listing.search(
          Riddle::Query.escape(search[:keywords] || ""),
          search_filter
        )


        begin
          DatabaseSearchHelper.success_result(models.total_entries, models, includes)
        rescue ThinkingSphinx::SphinxError => e
          Result::Error.new(e)
        end
      end

    end

    def to_radians(degrees)
      degrees * (Math::PI/180)
    end

    def search_out_of_bounds?(per_page, page)
      pages = (SPHINX_MAX_MATCHES.to_f / per_page.to_f)
      page > pages.ceil
    end

    def selection_groups(groups)
      if groups[:search_type] == :and
        groups[:values].flatten
      else
        groups[:values]
      end
    end
  end
end