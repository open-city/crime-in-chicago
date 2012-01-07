require "sinatra/base"
require "sinatra/reloader"
require "sinatra-initializers"
require "sinatra/r18n"

module Chicago
  module Crime
    class Application < Sinatra::Base
      enable :logging, :sessions
      enable :dump_errors, :show_exceptions if development?

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

      helpers Chicago::Crime::HtmlHelpers
      helpers Chicago::Crime::ViewHelpers

      get "/" do
        haml :index
      end
    end
  end
end
