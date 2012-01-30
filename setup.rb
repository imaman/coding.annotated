

class BabysitterSetup
  def self.configureTwitter config
    config.consumer_key = ""
    config.consumer_secret = ""
    config.oauth_token = ""
    config.oauth_token_secret = ""
    raise "This is just a template. For the real thing, use setup_PRODUCTION.rb"
  end

  def self.url
    "http://www.mysite.com"
    raise "This is just a template. For the real thing, use setup_PRODUCTION.rb"
  end

  def self.twitter_user
    "some-twitte-user-name"
    raise "This is just a template. For the real thing, use setup_PRODUCTION.rb"
  end
end

