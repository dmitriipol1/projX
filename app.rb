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

get '/:theme_id/:path' do
  @path = params[:path]
  theme_id = params[:theme_id]
  # layer = @path.size
  branch = @path[0]

  category = client.query("select * from theme where theme_id = #{theme_id}").first
  item = {'id' => '0',
          'answer_to_panel' => category['theme_text'],
          'link' => '0',
          'hint' => ''}
  @history = [item]

  # init and save history to the session pool
  if @path.size == 1
    question = client.query("SELECT * FROM questions where theme_id = #{theme_id} and question_id = 0 ")
    @answers = client.query("SELECT * FROM answers where theme_id = #{theme_id} and layer = 1 and branch = 1")
  else
    question_id = @path[0..(@path.size-2)]
    question = client.query("SELECT * FROM questions where theme_id = #{theme_id} and question_id = #{question_id}")
    @answers = client.query("SELECT * FROM answers where theme_id = #{theme_id} and layer = #{question.first['layer']} and branch = #{branch}")
    question_id.split('').each_with_index do |chr, index|
      answer = client.query("SELECT * FROM answers where theme_id = #{theme_id} and answer_id = #{chr.to_i} and layer = #{index+1} and branch = #{branch}")
      a = answer.first
      # a = {}
      # answer.each do |ans|
      #   if ans['answer_id'] == chr.to_i
      #     a = ans
      #   end
      # end
      item = {'id' => question_id,
              'answer_to_panel' => a['answer_text_to_panel'],
              'link' => question_id[0..(index)],
              'hint' => a['answer_text']}
      @history.push(item)
    end
  end

  session[:history] = @history
  @el = question.first
  erb :theme
end

post '/:theme_id/:path' do
  # @theme_id = params[:path]
  theme_id = params[:theme_id]
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
    if item != nil
      @history.push(item)
    end
    session[:history] = @history

    question = client.query("SELECT * FROM questions where theme_id = #{theme_id} and question_id = #{@next_question}")
    @el = question.first
    if @el != nil
      @answers = client.query("SELECT * FROM answers where theme_id = #{theme_id} and layer = #{@el['layer']} and branch = #{@branch}")
      if !@el['layer'].to_s.include? '99'
        erb :theme
      else
        erb :answer
      end
    end
  else
    redirect '/'
  end
  # erb :show
end

