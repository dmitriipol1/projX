require 'rubygems'
require 'sinatra'
# require 'sinatra/reloader'
require 'mysql2'

client = Mysql2::Client.new(
		:host => '85.93.128.108',
		:username => 'puser',
		:password => 'Puser12',
		:database => 'projx',
		:encoding => 'utf8',
		:reconnect => true
	)

use Rack::Session::Pool

get '/' do
	@themes = client.query('SELECT * FROM theme')
		erb :index
end

get '/:path' do
	@path = params[:path]
	layer = @path.size
	branch = @path[0]

	# init and save history to the session pool
	if @path.size == 1
		question = client.query('SELECT * FROM questions where question_id = 0')
		@answers = client.query('SELECT * FROM answers where layer = 1 and branch = 1')

		item = {'id' => '0',
            'answer_to_panel' => 'название категории',
            'link' => '0',
            'hint' => ''}
		@history = [item]
	else
		@history = []
		question_id = @path[0..(@path.size-2)]
		question = client.query("SELECT * FROM questions where question_id = #{question_id}")
		@answers = client.query("SELECT * FROM answers where layer = #{layer} and branch = #{branch}")
		question_id.split("").each_with_index do |chr, index|
			answer = client.query("SELECT * FROM answers where layer = #{index+1} and branch = #{branch}")
			a = {}
			answer.each do |ans|
				if ans['answer_id'] == chr.to_i
					a = ans
				end
			end
			item = {'id' => question_id,
							'answer_to_panel' => a['answer_text_to_panel'],
							'link' => question_id,
							'hint' => a['answer_text']}
			@history.push(item)
		end
	end

	session[:history] = @history
		@el = question.first
		erb :theme
end

post '/:path' do
	@theme_id = params[:path]
	if params[:radio] != nil
		data = params[:radio].split('text')
		@id = data[0]
		@next_question = data[0]
		@branch = @next_question[0]
		@text_to_panel = data[1]
		@hint_panel = data[2]

		# add new history
		@history = session[:history]
		item = {'id' => @id,
						'answer_to_panel' => @text_to_panel,
						'link' => @id,
						'hint' => @hint_panel}
		@history.push(item)
		session[:history] = @history

		question = client.query("SELECT * FROM questions where question_id = #{@next_question}")
		@el = question.first
		if (@el != nil) && (@el['layer'] != 99)
			@answers = client.query("SELECT * FROM answers where layer = #{@el['layer']} and branch = #{@branch}")
		end
		erb :theme
	else
		redirect '/'
	end
	# erb :show
end

