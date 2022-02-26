require "./config/environment"
require './app/server'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*' # 'localhost:3000', 'localhost:8080', '0.0.0.0:3000', '127.0.0.1:3000',
    resource '*',  headers: :any, methods: [:get, :post, :delete, :put, :patch, :options, :head]
  end
end
run Rack::URLMap.new("/" => TodoApi)
