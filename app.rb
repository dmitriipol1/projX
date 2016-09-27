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
		@results = client.query("SELECT * FROM questions WHERE question_id='0'")
		erb :index
end
