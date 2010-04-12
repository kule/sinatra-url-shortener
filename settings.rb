set :authorization_realm, "Protected zone"

configure :development do
  set :database, 'postgres://username:password@localhost/url_shortener_development'
  set :login, 'admin'
  set :password, 'secret'
end

configure :test do
  set :database, 'postgres://username:password@localhost/url_shortener_test'
  set :login, 'admin'
  set :password, 'secret'
end

configure :production do
  set :database, ENV['DATABASE_URL']
  set :login, 'admin'
  set :password, 'secret'
end