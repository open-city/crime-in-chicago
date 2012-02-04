module Crime
  module ViewHelpers
    def ward_count
      50
    end

    def ward_crime_hash(year)
      @ward_crime_hash = retain_in_memory(:"ward_crime_hash_#{year}") do
        DB.fetch(Crime::QUERIES[:ward_crime_hash], :year => year).all
      end
    end

    def ward_crime_max(year)
      ward_crime_hash(year).map { |h| h[:crime_count] }.max
    end

    def ward_detail(year)
      @ward_detail ||= ward_crime_hash(year).map do |hash|
        crime_percentage = number_to_percentage(hash[:crime_count].to_f / ward_crime_max(year))

        {
          :ward => hash[:ward],
          :crime_count => hash[:crime_count],
          :crime_percentage => crime_percentage
        }
      end
    end

    def ward_calendar_crime(ward, year)
      @ward_calendar_crime = retain_in_memory(:"calendar_crime_#{ward}_#{year}") do
        DB.fetch(Crime::QUERIES[:ward_crime_calendar], :ward => ward, :year => year).all
      end
    end

    def ward_calendar_crime_max(year)
      DB.fetch(Crime::QUERIES[:crime_max_year], :year => year).first[:crime_count].to_f
      #@ward_calendar_crime.map { |h| h[:crime_count] }.max
    end

    def ward_calendar_detail(ward, year)
      @crime_max_year = ward_calendar_crime_max(year)
      @ward_calendar_detail ||= ward_calendar_crime(ward, year).map do |hash|
        crime_percentage = number_to_percentage(hash[:crime_count].to_f / @crime_max_year)
        {
          :date => hash[:occurred_at],
          :crime_count => hash[:crime_count],
          :crime_percentage => crime_percentage,
          :crime_max => @crime_max_year
        }
      end
    end
    
    def ward_stats_crimes_per_year(ward)
      DB.fetch(Crime::QUERIES[:ward_crimes_per_year], :ward => ward).all
    end

    def current_menu
      @current_menu
    end
    
    def current_menu_class(menu_name)
      return "current" if current_menu == menu_name
    end
    
    def format_number(number)
      integer_part = number.to_i
      integer_part_string = integer_part.to_s.reverse.gsub(/(\d{3}(?=(\d)))/, "\\1,").reverse
      
      "#{integer_part_string}"
    end

    def map_ward(number)
      parameters = {
        :sensor => "true", :size => "138x100",
        :path => "color:0xc10202aa|fillcolor:0xc1020211|weight:1|enc:ecp~FfwyuOs@fiBpx@iCd^vI|NmErP{K~FsVvGg`@rHaOnlAeAr@rVpHdB?~Lpp@ePX~MjiAeBxGoFpd@kDX~hAxc@gC?{Kju@?eBujDkyA`@?_z@_O??hRyS`@?nT}jA`@?nUu_D?Vzh@a~A`@YtWq`@?",
        :maptype => "roadmap", 
        :style => [
          "feature:road|visibility:off|saturation:-100",
          "feature:landscape|saturation:-100|lightness:75",
          "feature:transit|visibility:off",
          "feature:poi|saturation:-100|lightness:60",
          "feature:water|hue:0x00b2ff"
        ]
      }

      params_array = parameters.map do |name, value|
        if value.is_a?(Array)
          params_array = value.map do |item|
            "#{name}=#{item}"
          end
          params_array
        else
          "#{name}=#{value}"
        end
      end

      "http://maps.googleapis.com/maps/api/staticmap?#{params_array.flatten.join("&")}"
    end
  end
end
