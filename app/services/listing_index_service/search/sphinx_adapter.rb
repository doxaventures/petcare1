module ListingIndexService::Search

  class SphinxAdapter < SearchEngineAdapter

    # http://pat.github.io/thinking-sphinx/advanced_config.html
    SPHINX_MAX_MATCHES = 1000

    INCLUDE_MAP = {
      listing_images: :listing_images,
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
            listing_id: numeric_search_match_listing_ids
          })

        if search[:location_name].present?
          limit = 10_000
          if (search[:lat].present? && search[:lat] > 0) && (search[:lng].present? && search[:lng] > 0)
            @coordinates = [to_radians(search[:lat]), to_radians(search[:lng])]
            # @coordinates = [search[:lat], search[:lng]]
          else
            latlng = Geocoder.coordinates(search[:location_name])
            @coordinates = [to_radians(latlng[0]), to_radians(latlng[1])] if latlng.present?
            # @coordinates = [latlng[0], latlng[1]] if latlng.present?
          end
          # with_geo = HashUtils.compact(
          #   {
          #     community_id: community_id,
          #     category_id: search[:categories], # array of accepted ids
          #     listing_shape_id: search[:listing_shape_id],
          #     price_cents: search[:price_cents],
          #     listing_id: numeric_search_match_listing_ids,
          #     geodist: 0.0..limit.to_f,
          #   })
          with = with.merge({geodist: 0.0..limit.to_f}) if @coordinates.present?
        end

        # date_range = nil
        if search[:date].present?
          date = search[:date].split("/")
          fortmat_date = [date[1], date[0], date[2]].join("/").to_datetime
        else
          fortmat_date = Time.now
        end
        date_range = (fortmat_date - 5.years)..fortmat_date
          # with = HashUtils.compact(
          #   {
          #     community_id: community_id,
          #     category_id: search[:categories], # array of accepted ids
          #     listing_shape_id: search[:listing_shape_id],
          #     price_cents: search[:price_cents],
          #     listing_id: numeric_search_match_listing_ids,
          #     created_at: date_range,
          #   })
        if date_range
          with = with.merge({created_at: date_range})
        end

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

        if @coordinates.present?
          search_filter = search_filter.merge({geo: @coordinates})
        end

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