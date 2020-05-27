require 'bundler/setup'
Bundler.require
if development?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
end
