require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions

get '/' do
  if session[:user].nil?
    "You are not in session ;w;"
    # erb :index

  else
    "You are in session!\nWelcome #{User.find(session[:user]).name}!"
    # erb :index_session

  end
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.find_by(mail: params[:mail])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  else
    session[:signin_error] = 'パスワードが間違っています'
    redirect '/login'
  end
  redirect '/'

  erb :login
end

get '/signup' do
  erb :signup
end

post '/signup' do
  @user = User.create(
    name: params[:name],
    mail: params[:mail],
    password: params[:password],
    password_confirmation: params[:password_confirmation])
  if @user.persisted?
    session[:user] = @user.id
    redirect '/'
  else
    redirect '/signup'
  end
  erb :signup
end

get '/logout' do
  session[:user] = nil
  redirect '/'
end