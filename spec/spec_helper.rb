require File.join(File.dirname(__FILE__), '..', 'url_shortener.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'base64'

# set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

def encode_credentials(username, password)
  "Basic " + Base64.encode64("#{username}:#{password}")
end

def valid_credentials
  encode_credentials('admin', 'secret')
end

def invalid_credentials
  encode_credentials('go', 'away')
end
