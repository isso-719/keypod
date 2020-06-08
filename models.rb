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
    format: { with: /^[0-9a-zA-Z]*$/ },
    length: { maximum: 7 }
  validates :mail,
    presence: true,
    format: { with: /\A([a-zA-Z0-9])+([a-zA-Z0-9\._-])*@([a-zA-Z0-9_-])+([a-zA-Z0-9\._-]+)+\z/ }
  validates :password_digest,
    length: { maximum: 7 }
end

class Workspace < ActiveRecord::Base
  has_many :keys
  belongs_to :user

  validates :url,
    presence: true
end

class Key < ActiveRecord::Base
  belongs_to :workspace
end