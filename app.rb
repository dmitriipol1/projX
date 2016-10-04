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
		@themes = client.query("SELECT * FROM questions")
		erb :index
end
