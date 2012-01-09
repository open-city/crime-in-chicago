module Chicago
  module Crime
    module ViewHelpers
      def current_menu
        @current_menu
      end
      
      def current_menu_class(menu_name)
        return "current" if current_menu == menu_name
      end
    end
  end
end

