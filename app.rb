require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

require 'browser/browser'
require 'browser/aliases'
Browser::Base.include(Browser::Aliases)

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

def browser_check
  ua = request.user_agent
  browser = Browser.new(ua)
  if browser.mobile?
    redirect '/sp'
  end
end

get '/sp' do
  ua = request.user_agent
  browser = Browser.new(ua)
  unless browser.mobile?
    redirect '/'
  end
  erb :mobile
end

get '/' do
  browser_check

  if session[:user].nil?
    erb :index
  else
    @workspaces = current_user.workspaces.order(updated_at: :desc)
    erb :index_session
  end
end

get '/login' do
  browser_check

  erb :login
end

post '/login' do
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    redirect '/'
  else
    session[:signin_error] = 'メールアドレス、またはパスワードが間違っています'
    erb :login
  end
end

get '/signup' do
  browser_check

  erb :signup
end

post '/signup' do
  if params[:name] == "" || params[:mail] == "" || params[:password] == "" || params[:password_confirmation] == ""
    session[:signup_error] = '入力されていない項目があります'
    erb :signup
  else
    @user = User.create(
      name: params[:name],
      mail: params[:mail],
      password: params[:password],
      password_confirmation: params[:password_confirmation])
    if @user.persisted?
      session[:user] = @user.id
      redirect '/'
    else
      if User.find_by(name: params[:name]).present?
        session[:signup_error] = 'ユーザー名がすでに存在します'
      elsif User.find_by(mail: params[:mail]).present?
        session[:signup_error] = 'このメールアドレスは登録済みです'
      else
        session[:signup_error] = '入力を確認してください'
      end
      erb :signup
    end
  end
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end

get '/workspace/create' do
  browser_check

  erb :workspace_create
end

post '/workspace/create' do
  random = SecureRandom.urlsafe_base64

  if Workspace.find_by(url: random).nil?
    if params[:name] == ""
      name = "名称未設定"
    else
      name = params[:name]
    end
    current_user.workspaces.create(
      name: name,
      description: params[:description],
      url: random
    )
    workspace = Workspace.last
    strs = ('a'..'z').to_a
    strs.push(*'0'..'9')
    strs.each do |str|
      workspace.keys.create(
        key: str
      )
    end
    redirect '/'

  else
    "内部エラーが発生しました。もう一度操作をやり直してください"
  end

end

post '/workspace/delete/:id' do
  workspace = Workspace.find(params[:id])
  keys = Key.where(workspace_id: workspace.id)
  workspace.destroy
  keys.each do |key|
    key.destroy
  end
  redirect '/'
end

get '/workspace/:url' do
  browser_check

  @workspace = Workspace.find_by(url: params[:url])

  @strs = ('a'..'z').to_a
  @strs.push(*'0'..'9')

  erb :workspace
end

before '/workspace/edit/:url/:id' do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = "isso719"
    config.api_key = "786826389449828"
    config.api_secret = "crf1Vx1zwcf4m_dJmOe_jpOjiI8"
    config.secure = true
  end
end

post '/workspace/edit/:url/:id' do
  workspace = Workspace.find_by(url: params[:url])
  key = workspace.keys.find(params[:id])

  msc_url = key.path
  data_type = key.data_type
  if params[:file]
    msc_url = ""
    data_type = "cloudinary"
    msc = params[:file]
    tempfile = msc[:tempfile]
    upload = Cloudinary::Uploader.upload(tempfile.path,:resource_type => :video)
    msc_url = upload["secure_url"]

  elsif params[:youtube]
    tmp = params[:youtube].split("?v=")
    if tmp[1].nil?
      msc_url = params[:youtube][-11 .. -1]
    else
      msc_url = tmp[1][0 .. 10]
    end
    data_type = "youtube"

  end

  if params[:description] == ""
    desc = "説明なし"
  else
    desc = params[:description]
  end

  key.update(
    path: msc_url,
    data_type: data_type,
    description: desc
  )

  redirect "/workspace/#{workspace.url}"

end

post '/workspace/edit/delete/:url/:id' do
  workspace = Workspace.find_by(url: params[:url])
  key = workspace.keys.find(params[:id])

  key.update(
    path: nil,
    data_type: nil,
    description: nil
  )

  redirect "/workspace/#{workspace.url}"
end