require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"
require "sinatra/json"
require "sequel"
require "uri"
require "facets/string"

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


#    (2002..2011).each do |year|
#      dataset = DB.fetch(QUERIES[:crime_max_daily_year], :year => year)
#      retain_in_cache(dataset.sql) do
#        dataset.first[:max].to_i
#      end
#    end


    get "/" do
      @current_menu = "home"
      haml :index
    end
    
    get "/wards/:ward" do
      haml :"wards/index", :locals => {
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

class String
  def titleize
    split(/(\W)/).map(&:capitalize).join
  end
end
