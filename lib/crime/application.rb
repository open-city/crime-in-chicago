require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"
require "sinatra/json"
require "sequel"
require "uri"
require "facets/string"

class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end

module Crime
  class Application < Sinatra::Base
    include Cacheable
    extend Cacheable

    puts "settings: #{dalli_settings.inspect}"

    enable :logging, :sessions
    enable :dump_errors, :show_exceptions if development?

    set :cache, Dalli::Client.new(*dalli_settings)

    configure :development do
      register Sinatra::Reloader
    end

    configure :production do
      require "newrelic_rpm"
    end

    register Sinatra::Initializers
    register Sinatra::R18n

    before do
      session[:locale] = params[:locale] if params[:locale]
    end

    use Rack::Logger
    use Rack::Session::Cookie

    helpers HtmlHelpers
    helpers Crime::ViewHelpers
    helpers Sinatra::JSON

    #catch-all for haml pages
    get "/:page" do |page_name|
      template = File.join(settings.views, page_name + ".haml")
      if File.exists?(template)
        @current_menu = page_name
        haml page_name.to_sym
      else
        pass
      end
    end
    
    #home page
    get "/" do
      @current_menu = "home"
      haml :index
    end
    
    #ward detail page
    get "/wards/:ward" do
      haml :"wards/show", :locals => {
        :ward => params[:ward]
      }
    end
    
    #expanded map from detail page
    get "/wards/map/:ward" do
      haml :"wards/map", :layout => false, :locals => {
        :ward => params[:ward]
      }
    end
    
    #partials for ward detail page
    get "/wards/:ward/:year/partials/timeline-history" do
      @current_menu = "home"
      haml :"ward-history", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year]
      }
    end

    get "/wards/:ward/:year/partials/statistics/crime" do
      @crimes_by_year = statistic_crimes_by_ward(params[:ward], "2001")

      haml :"ward/statistics/crime", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year]
      }
    end

    get "/wards/:ward/:year/partials/statistics/category" do
      @categories_by_year = statistic_categories_by_ward_and_year(params[:ward], params[:year])

      haml :"ward/statistics/category", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year]
      }
    end
    
    get "/wards/:ward/:year/:month/partials/statistics/category" do
      @categories_by_month = statistic_categories_by_ward_and_year_and_month(params[:ward], params[:year], params[:month])

      haml :"ward/statistics/category_month", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year], :month => params[:month]
      }
    end

    get "/wards/:ward/:year/partials/statistics/sparkline" do
      haml :"ward/statistics/sparkline", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year]
      }
    end

    get "/wards/:year/partials/crime-columns" do
      haml :"ward-crime-columns", :layout => false, :locals => {
        :year => params[:year]
      }
    end
    
    get "/crime_type/:fbi_code/partials/description" do 
      data = find_by_fbi_code(params[:fbi_code])
      {
        :template => erb(:"mustache/description.html"),
        :name => data[:name],
        :friendly_description => data[:friendly_description],
        :legal_definition => data[:legal_definition]
      }.to_json
    end
    
    get "/wards/:ward/:fbi_code/partials/subcategories" do 
      haml :"ward-subcategory", :layout => false, :locals => {
        :ward => params[:ward], :fbi_code => params[:fbi_code]
      }
    end

    get "/api/:year/wards/:ward/crime/calendar" do
      content_type :json
      ward_calendar_detail(params[:ward], params[:year]).to_json
    end

    # API
    get "/api/wards/:ward/:year/statistics/map.json" do
      {
        :template => erb(:"mustache/map.html"),
        :class => "map", :header => "Ward location"
      }.to_json
    end

    get "/api/wards/:ward/:year/statistics/category.json" do
      categories = statistic_categories_by_ward_and_year(params[:ward], params[:year])
      max = categories.map{|c| c[:crime_count] }.max
      {
        :template => erb(:"mustache/category.html"),
        :class => "category", :header => "Most frequent",
        :categories => categories.map { |c|
          {
            :crime_count => c[:crime_count],
            :category_name => c[:category_name].titleize,
            :width => ((c[:crime_count].to_f / max) * 100).round
          }
        }
      }.to_json
    end

    get "/api/wards/:ward/:year/:month/statistics/category.json" do
      categories = statistic_categories_by_ward_year_month(params[:ward], params[:year], params[:month])
      max = categories.map{|c| c[:crime_count] }.max
      {
        :template => erb(:"mustache/category.html"),
        :class => "category", :header => "Most frequent",
        :categories => categories.map { |c|
          {
            :crime_count => c[:crime_count],
            :fbi_code => c[:fbi_code],
            :width => ((c[:crime_count].to_f / max) * 100).round
          }
        }
      }.to_json
    end

    get "/api/wards/:ward/:year/statistics/crime.json" do
      crimes = statistic_crimes_by_ward(params[:ward], "2001")
      max = crimes.map{ |c| c[:crime_count_for_year] }.max
      year = params["year"].to_i
      previous_year = year - 1 if year > 2002
      
      previous_year_diff = year_comparison(crimes, year, (previous_year ? previous_year : year))
      previous_year_diff_class = ""
      if (previous_year_diff > 0) 
        previous_year_diff_class = "label-red"
        previous_year_diff = "+#{previous_year_diff}"
      elsif (previous_year_diff < 0) 
        previous_year_diff_class = "label-green"
      end
        
      previous_year_diff = "#{previous_year_diff}%"
      
      {
        :template => erb(:"mustache/crime.html"),
        :class => "crime", :header => "Number of crimes",
        :minimum_year => crimes.map{|hash| hash[:year]}.min,
        :maximum_year => crimes.map{|hash| hash[:year]}.max,
        :previous_year_diff => previous_year_diff,
        :previous_year_diff_class => previous_year_diff_class,
        :previous_year => params["year"].to_i - 1,
        :current_year_crimes => number_with_delimiter(crimes.detect{|hash| hash[:year].to_s == params["year"]}[:crime_count_for_year]),
        :current_year => params["year"],
        :crimes => crimes.map { |c|
          {
            :current => (c[:year].to_s == params[:year]) ? "current" : "",
            :height => number_to_percentage(c[:crime_count_for_year].to_f / max),
            :width => number_to_percentage(1.0 / crimes.count),
            :title => "#{c[:year]} - #{number_with_delimiter c[:crime_count_for_year]} crimes"
          }
        }
      }.to_json
    end

    get "/api/wards/:ward/:year/statistics/sparkline.json" do
      {
        :template => erb(:"mustache/sparkline.html"),
        :data => sparkline_by_ward_and_year({
          :ward => params[:ward],
          :year => params[:year]
        }).join(",")
      }.to_json
    end
  end
end

