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
		@theme_id = params[:theme_id]
		@history = ['1']
		question = client.query("SELECT * FROM questions where theme_id = #{@theme_id} and layer = 1")
		@el = question.first
		@answers = client.query("SELECT * FROM answers where layer = #{@el['layer']}")
		erb :theme
end

post '/:theme_id' do
		@theme_id = params[:theme_id]
		question_id = params[:radio]
		question_text = params[:question_text]
		@history = Array.new [question_text + '<br>' + question_id]
		# @history.push(question_text)
		question = client.query("SELECT * FROM questions where question_id = #{question_id}")
		@el = question.first
		if @el != nil 
			@answers = client.query("SELECT * FROM answers where layer = #{@el['layer']}")
		end
		erb :theme

	# erb :show
end

