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
    @workspaces = session_user.workspaces.order(created_at: :desc)
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
  redirect '/'
end

post '/workspace/delete/:id' do
  workspace = Workspace.find(params[:id])
  workspace.destroy
  redirect '/'
end