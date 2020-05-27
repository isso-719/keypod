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
  if user && user.authenticate(password: params[:password])
    session[:user] = user.id
    redirect '/'
  else
    redirect '/login'
  end

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
end