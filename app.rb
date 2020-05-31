require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions

def session_user
  User.find(session[:user])
end

get '/' do
  if session[:user].nil?
    erb :index
  else
    @workspaces = session_user.workspaces.order(updated_at: :desc)
    erb :index_session
  end
end

get '/login' do
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
      erb :signup
    end
  end
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end

get '/workspace/create' do
  erb :workspace_create
end

post '/workspace/create' do
  random = SecureRandom.urlsafe_base64
  session_user.workspaces.create(
    name: params[:name],
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
  @workspace = Workspace.find_by(url: params[:url])

  @strs = ('a'..'z').to_a
  @strs.push(*'0'..'9')

  erb :workspace
end

get '/workspace/edit/:url' do
  @workspace = Workspace.find_by(url: params[:url])

  erb :workspace_edit
end

before '/workspace/edit/:url' do
  Dotenv.load
  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUD_NAME"]
    config.api_key = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
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
    msc_url = upload["url"]
  end

  key.update(
    path: msc_url,
    data_type: data_type,
    description: params[:description]
  )

  redirect "/workspace/edit/#{workspace.url}"

end