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

    enable :logging, :sessions
    enable :dump_errors, :show_exceptions if development?

    set :cacheable, {:server => "localhost:11211"}

    configure :development do
      register Sinatra::Reloader
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


    get "/" do
      @current_menu = "home"
      haml :index
    end
    
    get "/wards/:ward" do
      haml :"wards/show", :locals => {
        :ward => params[:ward]
      }
    end
    
    get "/wards/map/:ward" do
      haml :"wards/map", :layout => false, :locals => {
        :ward => params[:ward]
      }
    end

    get "/wards/:ward/:year/partials/timeline" do
      @current_menu = "home"
      haml :"ward", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year],
        :map_src => map_ward(params[:ward], "small")
      }
    end
    
    get "/wards/:ward/:year/partials/timeline-history" do
      @current_menu = "home"
      haml :"ward-history", :layout => false, :locals => {
        :ward => params[:ward], :year => params[:year]
      }
    end

    get "/wards/:ward/:year/partials/statistics/crime" do
      @crimes_by_year = statistic_crimes_by_ward(params[:ward])

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
            :primary_type => c[:primary_type].titleize,
            :width => ((c[:crime_count].to_f / max) * 100).round
          }
        }
      }.to_json
    end

    get "/api/wards/:ward/:year/statistics/crime.json" do
      crimes = statistic_crimes_by_ward(params[:ward])
      max = crimes.map{ |c| c[:crime_count_for_year] }.max
      year = params["year"].to_i
      previous_year = year - 1 if year > 2003
      {
        :template => erb(:"mustache/crime.html"),
        :class => "crime", :header => "Number of crimes",
        :minimum_year => crimes.map{|hash| hash[:year]}.min,
        :maximum_year => crimes.map{|hash| hash[:year]}.max,
        :previous_year_diff => year_comparison(crimes, year, previous_year),
        :previous_year => params["year"].to_i - 1,
        :current_year_crimes => number_with_delimiter(crimes.detect{|hash| hash[:year].to_s == params["year"]}[:crime_count_for_year]),
        :current_year => params["year"],
        :crimes => crimes.map { |c|
          {
            :current => (c[:year].to_s == params[:year]) ? "current" : "",
            :height => number_to_percentage(c[:crime_count_for_year].to_f / max),
            :title => "#{c[:year]} - #{number_with_delimiter c[:crime_count_for_year]} crimes"
          }
        }
      }.to_json
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

    get "/api/wards/:year/crime_count.json" do
      ward_crime_columns(params[:year]).to_json
    end
    
    get "/wards/:ward/:primary_type/partials/subcategories" do 
      haml :"ward-subcategory", :layout => false, :locals => {
        :ward => params[:ward], :primary_type => params[:primary_type]
      }
    end

    get "/api/:year/wards/:ward/crime/calendar" do
      content_type :json
      ward_calendar_detail(params[:ward], params[:year]).to_json
    end

    get "/:page" do |page_name|
      template = File.join(settings.views, page_name + ".haml")
      if File.exists?(template)
        @current_menu = page_name
        haml page_name.to_sym
      else
        pass
      end
    end

    get "/crime_data/group_by_ward" do
      #DB['select now()'].all.to_s
      year = params[:year]
      query = "select ward, count(*) from crimes where date_part('year', occurred_at) = #{year} and trim(ward) != '' group by ward order by ward::integer"
      json DB[query].all
    end
  
    get "/crime_data/group_by_date" do
      year = params[:year]
      ward = params[:ward]
      query = "select date(occurred_at)::text, count(*) from crimes where date_part('year', occurred_at) = #{year} and ward = '#{ward}' group by date(occurred_at) order by date(occurred_at);"
      json DB[query].all
    end
  
    get "/crime_data/group_by_year" do
      query = "select date_part('year',occurred_at) as year, count(*) from crimes where ward = :ward group by date_part('year', occurred_at) order by year;"
      json DB.fetch(query, :ward => params[:ward]).all
    end
  end
end

