require File.dirname(__FILE__) + '/spec_helper'

describe 'Url Shortener' do
  def app
    @app ||= Sinatra::Application
  end
  
  context "Creation" do
    it "should show the home page" do
      get '/'
      last_response.should be_ok
    end
    
    context "with invalid login" do
      it "should not allow url to be posted without authentication" do
        post '/', {:url => 'http://example.com/'}
        last_response.status.should == 401
      end

      it "should not allow url to be posted with incorrect login" do
        post '/', {:url => 'http://example.com/'}, {'HTTP_AUTHORIZATION' => invalid_credentials}
        last_response.status.should == 401
      end
    end

    context "with valid login" do
      before(:each) do 
        @short_url = mock(ShortUrl)
        @short_url.stub!(:key).and_return('4ER')
        ShortUrl.stub!(:new).and_return(@short_url)
      end

      it "saves the url" do
        @short_url.should_receive(:save).and_return(true)
        post '/', {:url => 'http://example.com/'}, {'HTTP_AUTHORIZATION'=> valid_credentials}
      end
      
      it "without a url it redirects to error page" do
        @short_url.stub!(:save).and_return(false)
        @short_url.stub!(:errors).and_return([])
        @short_url.stub!(:url).and_return(nil)
        post '/', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('admin', 'secret')}
        last_response.should be_ok
        last_response.body.should =~ /error/i
      end
    
      it "with a url it redirects to success page" do
        @short_url.stub!(:save).and_return(true)
        post '/', {:url => 'http://example.com/'}, {'HTTP_AUTHORIZATION'=> valid_credentials}
        last_response.should be_redirect
        last_response["Location"].should =~ /\/success\/4ER/
      end
    end
  end
  
  context "Redirection" do
    before(:each) do
      @long_url = 'http://example-long-url.com'
      @short_url = mock(ShortUrl)
      @short_url.stub!(:click).and_return(true)
      @short_url.stub!(:url).and_return(@long_url)
    end
    
    it "redirects when given a valid short url" do
      ShortUrl.should_receive(:find_by_key).with('4ER').and_return(@short_url)
      get '/l/4ER'
      last_response.should be_redirect
      last_response["Location"].should == 'http://example-long-url.com'
    end

    it "displays 404 page when short url is invalid" do
      ShortUrl.should_receive(:find_by_key).with('invalid').and_return(nil)
      get '/l/invalid'
      last_response.status.should == 404
    end
  
    it "displays 404 page when short url doesn't exist" do
      ShortUrl.should_receive(:find_by_key).with('A2Ph').and_return(nil)
      get '/l/A2Ph'
      last_response.status.should == 404
    end
  
    it "logs the time & referrer when given a valid short url" do
      referrer = 'http://example-referrer.com'
      ShortUrl.stub!(:find_by_key).and_return(@short_url)
      @short_url.should_receive(:click).with(referrer)
      get '/l/4ER', {}, {'HTTP_REFERER' => referrer}
    end
  end
  
  context "Admin" do
    context "Short Urls" do
      it "shows list of short urls" do
        ShortUrl.should_receive(:all).and_return([ShortUrl.new])
        get '/admin', {}, {'HTTP_AUTHORIZATION'=> encode_credentials('admin', 'secret')}
        last_response.should be_ok
      end

      it "should not allow access to short urls list without authentication" do
        get '/admin'
        last_response.status.should == 401
      end
    end
    
    context "Referrers List" do
      it "shows list of referers for a specific short url" do
        ShortUrl.should_receive(:find_by_key).with('4ER').and_return(ShortUrl.new)
        get '/admin/clicks/4ER', {}, {'HTTP_AUTHORIZATION'=> valid_credentials}
      end

      it "should not allow access to referrers list without authentication" do
        get '/admin/clicks/4ER'
        last_response.status.should == 401
      end
    end
  end
end
