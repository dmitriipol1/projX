require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'mysql2'

client = Mysql2::Client.new(
	:host => "85.93.128.108", 
	:username => "puser", 
	:password => "Puser12",
	:database => "projx"
	)

get '/' do
		@themes = client.query("SELECT * FROM theme")
		erb :index
end

get '/:theme_id' do
		theme_id = params[:theme_id]
		@history = ['first', 'second']
		question = client.query("SELECT * FROM questions where theme_id = #{theme_id} and layer = 1")
		@el = question.first
		@answers = client.query("SELECT * FROM answers where answers_group = #{@el['answers_id']}")
		erb :theme
end


post '/' do
	erb :show
end