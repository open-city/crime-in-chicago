module Crime
  module ViewHelpers
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
