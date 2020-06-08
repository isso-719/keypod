require 'bundler/setup'
Bundler.require
if development?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :workspaces

  validates :name,
    presence: true,
    uniqueness: true,
    format: { with: /\A[0-9a-zA-Z]*\z/ },
    length: { minimum: 7 }
  validates :mail,
    presence: true,
    uniqueness: true,
    format: { with: /\A([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+\z/ }
  validates :password_digest,
    presence: true,
    length: { minimum: 7 }
end

class Workspace < ActiveRecord::Base
  has_many :keys
  belongs_to :user

  validates :url,
    uniqueness: true
end

class Key < ActiveRecord::Base
  belongs_to :workspace
end