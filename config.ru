require 'url_shortener'

set :env,      :production
disable :run, :reload

run Sinatra::Application
