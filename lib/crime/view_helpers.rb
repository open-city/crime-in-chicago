module Crime
  module ViewHelpers
    def ward_count
      50
    end

    def ward_detail
      # TODO: Remove when tied to database hash responses
      # { :ward => 1, :crime_count => 400, :crime_percentage => 42% }
      #
      # Formuls
      # ward = ward number
      # crime_count = individual ward crimes
      # crime_percentage = (count / max) * 100 }
      # crime_severity = Not very severe | Moderately severe | Very severe

      1.upto(ward_count).map do |number|
        crime_max_count = 1200
        crime_count = rand(crime_max_count)
        crime_percentage = number_to_percentage(crime_count.to_f / crime_max_count)
        {
          :ward => number,
          :crime_count => crime_count,
          :crime_percentage => crime_percentage,
          :crime_severity => severity_from_percentage(crime_percentage)
        }
      end
    end

    def severity_from_percentage(percentage)
      if percentage < 33
        "Not very severe"
      elsif percentage < 66
        "Moderately severe"
      else
        "Very severe"
      end
    end

    def current_menu
      @current_menu
    end
    
    def current_menu_class(menu_name)
      return "current" if current_menu == menu_name
    end

    def ward_image()
      return <<-eos
http://maps.googleapis.com/maps/api/staticmap?
size=138x100
&sensor=false
&path=
color:0xc10202aa
|fillcolor:0xc1020211
|weight:1
|enc:ecp~FfwyuOs@fiBpx@iCd^vI|NmErP{K~FsVvGg`@rHaOnlAeAr@rVpHdB?~Lpp@ePX~MjiAeBxGoFpd@kDX
&maptype=roadmap
&style=feature:road|visibility:off|saturation:-100
&style=feature:landscape|saturation:-100|lightness:75
&style=feature:transit|visibility:off
&style=feature:poi|saturation:-100|lightness:60
&style=feature:water|hue:0x00b2ff'
      eos
    end
  end
end
