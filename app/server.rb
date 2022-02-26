# server.rb
require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'

require 'sinatra/cross_origin'

set :allow_origin, :any
set :allow_methods, [:get, :post, :options]
set :allow_credentials, true
set :max_age, "1728000"
set :expose_headers, ['Content-Type']

configure do
  enable :cross_origin
end

# a valid note id: 6206e373e11c713c6250549c , 6206e3bce11c713c6250549d

# DB Setup

class TodoApi < Sinatra::Base
  # read the documentation w dah ely tle3t beeh
  register Sinatra::CrossOrigin
  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
   
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
   
    200
  end
  class Note
    include Mongoid::Document

    field :title, type: String
    field :note, type: String

    index({ title: 1 }, { unique: true })

    scope :title, ->(title) { where(title: /#{title}/) }
    scope :note, ->(note) { where(note: /#{note}/) }
  end

  get '/' do
    'Welcome to your to-do list'.to_json
    # mn8er el .to_json kan bydyny error => SyntaxError: JSON.parse: unexpected character at line 1 column 1 of the JSON data
  end

  get '/try/:name' do
    "Hello #{params['name']}".to_json # bagarab el params
  end

  class Serializer
    def initialize(note)
      @note = note
    end

    def as_json(*)
      data = {
        id: @note.id.to_s,
        title: @note.title.to_s,
        note: @note.note.to_s
      }
      data[:errors] = @note.errors if @note.errors.any?
      data
    end
  end

  before do
    content_type 'application/json'
  end

  helpers do # made to return link for newly created notes
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      # (||=) assignment operator which means => if x is false || nil set it to the given, in our case the link
      #
    end

    def json_params
      JSON.parse(request.body.read)
    rescue StandardError => e
      halt 400, { message: 'Invalid Json' }.to_json
    end
  end

  get '/todo' do
    notes = Note.all

    %i[title note].each do |filter|
      notes = notes.send(filter, params[filter]) if params[filter]
      # .send deh btdwr 3ala el method fel file , so basically you have to pass the paramters ely homa filter => which can be :title aw :note && pass kman el
      # params[filter] ely da5elak mn el user
    end

    notes = notes.title(params[:title]) if params[:title]
    notes.map { |note| Serializer.new(note) }.to_json
  end

  get '/todo/:id' do
    note = Note.where(id: params[:id]).first
    return Serializer.new(note).to_json if note

    halt(404, { message: 'Note Not Found' }.to_json)
  end

  post '/todo' do
    note = Note.new(json_params)
    if note.save
      response.headers['Location'] = "#{base_url}/todo/#{note.id}"
      status 201
    else
      status 422
      body Serializer.new(note).to_json # body?
    end
  end

  patch '/todo/:id' do |id|
    note = Note.where(id: id).first
    halt(404, { message: 'Book Not Found' }.to_json) unless note
    if note.update_attributes(json_params)
      Serializer.new(note).to_json
    else
      status 422
      body Serializer.new(note).to_json
    end
  end

  delete '/todo/:id' do |id|
    note = Note.where(id: id).first
    halt(404, { message: 'Book Not Found' }.to_json) unless note
    note.destroy # destroy deletes the child document and applies callbacks
    status 204
    # curl m4 4a8al curl - i -X DELETE -H "Content-Type: application/json" http://localhost:4567/todo/6206e3bce11c713c6250549d
  end
end
