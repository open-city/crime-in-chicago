module Chicago
  module Crime
    module HtmlHelpers
      def include_stylesheets name, options
        href = "/stylesheets/#{name}.css" unless name.to_s.match(/^http/)
        content_tag :link, options.merge(:rel => "stylesheet", :href => (href || name))
      end

      def include_javascripts name, options={}
        href = "/javascripts/#{name}.js" unless name.to_s.match(/^http/)
        content_tag :script, :type => "text/javascript", :src => (href || name)
      end

      def image name, options={}
        src = "/images/#{name}" unless name.to_s.match(/^http/)
        content_tag :img, options.merge(:alt => name, :src => (src || name))
      end

      # TODO: correct to include link text
      def link_to name, href, options={}
        content_tag :a, :href => href
      end

      def content_tag tag, options={}
        element = "<#{tag}"
        options.each do |name, value|
          element << " #{name}=\"#{value}\""
        end

        if [:script].include? tag
          element << "></script>"
        else
          element << "/>"
        end
        element
      end
    end
  end
end
