## TDD ~ Test Driven Development
require 'spec_helper'
require './app/server'

RSpec.describe TodoApi do
  def app
    TodoApi
  end

  # describe 'GET todos' do   # describe return subclass of exampleGroup
  #   context 'no todos' do # same applies to context
  #     there is no functional difference btween context and describe. However
  #     describe => test under same functionality
  #     context => test under same functionality of the **same state**
  #     zy hena we need to get todos bas we have several states lel todos => none,several,all
  #     it 'returns no todo' do # returns instance of Example , serves as a wrapper for an instance of the ExampleGroup
  #       get '/'
  #       expect(last_response.body).to eq('')
  #       expect(last_response.status).to eq 200
  #     end
  #   end
  # end

  # describe Object => this object need to be found in your main file
  # you can use let(:calculator) {Object.new} to be able to use it several times
  # it => xit disables test
  # expectations are called matchers => .to eq/be_something
  # expectations for raising errors should be wrapped in block why                 ????
  describe 'homepage' do
    context 'Hello_world' do
      it 'returns Welcome to your to-do list' do
        get '/'
        expect(JSON.parse(last_response.body)).to eq('Welcome to your to-do list')
      end
    end
  end

  # the list of the notes
  # => can be empty
  # => can be full which will return the notes

  describe 'GET todos' do
    context 'none added' do
      it 'returns null' do
        get '/todo'
        expect(last_response.status).to eq(200)
        rvalue = JSON.parse(last_response.body)
        expect(rvalue).to be_empty
      end
    end
    context 'notes found' do
      before do
        @todos = []
        5.times do
          @todos.push TodoApi::Note.create(title: 'title', note: 'note')
        end
      end
      it 'returns notes' do
        get '/todo'
        expect(last_response.status).to eq(200)
        rvalue = JSON.parse(last_response.body).map do |todo|
          todo['id']
        end
        expected = @todos.map do |todo|
          todo['_id'].to_s
        end
        expected.reverse!
        expect(rvalue).to match_array(expected)
      end
    end
  end

  # before, after are called hooks => they are executed before each example

  # get note by id
  # => either valid id that is found
  # => or id not found

  describe 'GET todos by id' do
    context 'id found' do
      before do
        @todo = []
        @todo.push TodoApi::Note.create(title: 'trial', note: 'trial note')
      end
      it 'returns success' do
        wanted = @todo.map do |todo|
          todo['_id'].to_s
        end
        get "/todo/#{wanted.first()}"# el taree2a deh m4 sa7 mafrood 
        expect(last_response.status).to eq(200)

        expect(JSON.parse(last_response.body)).to include( "id" => wanted.first)
        # el expectations fel documentation olyl
      end
    end
    context 'id not found' do
      it 'returns Note Not Found' do
        get "/todo/#{"5324"}"
        expect(last_response.status).to eq(404)
        expect(JSON.parse(last_response.body).values).to include('Note Not Found')
      end
    end
  end
end
# adding a note
# => either invalid json
# => or could not add note
# => or success

#   describe 'POST note' do # m4 3aref ad5lo ezay wrong json, same for the semantics thing
#     context 'invalid json' do
#       it 'returns Invalid Json' do
#         post '/todo'
#         expect(last_response.body).to eq('Invalid Json')
#         expect(last_response.status).to eq(404)
#       end
#     end
#     context 'coudnt add due to semantics error' do
#       it 'returns the input' do
#         post '/todo'
#         expect(last_response.body).to eq # #complete
#         expect(last_response.status).to eq(422) # unproccessible
#       end
#     end
#     context 'added done' do
#       it 'returns input' do
#         post '/todo'
#         expect(last_response.body).to eq # #compleete
#         expect(last_response.status).to eq(201)
#       end
#     end
#   end
# end

##############################################
# double is an object that stands in for an object in your system during running examples
# Verifying doubles verifies that doubles you made exists in your system with same paramters ex. book = instanse_double("Book", pages=>200)
# double('message that appears in failure', object (:key=>value))
# when => allow(something).to recieve_message_chain(:anything) => this means that this something.anything will be accepted and it will return whatever value assigned to it
# ex allow(double).to receive_message_chain("foo.bar") { :baz }
