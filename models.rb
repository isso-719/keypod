require 'bundler/setup'
Bundler.require
if development?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :workspaces
end

class Workspace < ActiveRecord::Base
  has_many :keys
  belongs_to :user
end

class Key < ActiveRecord::Base
  belongs_to :workspace
end