helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def authorize(login, password)
    login == settings.login && password == settings.password
  end
  
  def display_errors(obj)
    obj.errors.to_s
  end

  def cycle
    %w{even odd}[@_cycle = ((@_cycle || -1) + 1) % 2]
  end
  
  def short_url_from_key(key)
    link = "http://#{request.host_with_port}/l/#{key}"
    link_to(link, link)
  end
  
  def display_datetime(datetime)
    datetime.strftime("%A, %e %B %Y at %H:%M%p") unless datetime.nil?
  end
  
  def truncate(text, limit)
    text.slice(0...(limit-3)) + '...' unless text.nil?
  end
  
  def link_to(title, url)
    "<a href='#{url}' title='#{h(title)}'>#{h(title)}</a>"
  end
end