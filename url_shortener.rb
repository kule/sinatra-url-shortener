require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'erb'
require 'base58'
# Used local version instead as current sinatra/authorization gem doesn't work with sinatra 1.0
require File.join(File.dirname(__FILE__), 'lib', 'authorization.rb')

#App Files

require File.join(File.dirname(__FILE__), 'settings.rb')
require File.join(File.dirname(__FILE__), 'helpers.rb')
require File.join(File.dirname(__FILE__), 'models.rb')


# Creation
get '/' do
  @short_url = ShortUrl.new
  erb :index
end

post '/' do
  login_required
  @short_url = ShortUrl.new(:url => params[:url])
  if @short_url.save
    redirect "/success/#{@short_url.key}"
  else
    erb :error
  end
end

get '/success/:key' do |key|
  @short_url = ShortUrl.find_by_key(key)
  erb :success
end

# Redirection
get %r{^/l/([a-zA-Z0-9]+)} do |key|
  if @short_url = ShortUrl.find_by_key(key)
    @short_url.click(request.referer)
    redirect @short_url.url
  else
    raise Sinatra::NotFound
  end
end

# Admin
get '/admin' do
  login_required
  @short_urls = ShortUrl.all
  erb :admin
end

get '/admin/clicks/:key' do |key|
  login_required
  @short_url = ShortUrl.find_by_key(key)
  erb :admin_clicks
end


