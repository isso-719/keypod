require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions

get '/' do
  if session[:user].nil?
    erb :index

  else
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
      session[:signup_error] = 'パスワードが一致しません'
      erb :signup
    end
  end
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end