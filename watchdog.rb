require 'rubygems'
require 'net/http'
require 'uri'
require 'twitter'
require 'twitter_setup_production'

class Babysitter
  def initialize(checker, http_client, alerter)
    @checker = checker
    @http_client = http_client
    @alerter = alerter
  end

  def run(url)
    if @checker.check(@http_client.fetch(url)) == :bad
      @alerter.alert
    end
  end
end

class Checker
  attr_accessor :min_length

  def initialize(flags)
    @min_length = 1000
   if !flags.include? :check_length 
      @min_length = 0
    end
    @flags = flags
  end

  def check(html)
    if html.length < min_length 
      return :bad
    end
    if (@flags.include? :check_content) && !html.include?("NEW DESIGN STARTS HERE")
      return :bad
    end
    return :ok
  end
end

class Fetcher
  def fetch(url)
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    response.body
  end
end

class Alerter 
  def initialize 
    Twitter.configure do |config|
      BabysitterSetup.configureTwitter config
   end
  end

  def alert
    t = Time.now
    Twitter.update("Alert fired at " + t.strftime("%a, %H:%M T%z") +
                   " - @" + BabysitterSetup.twitter_user + " - please check!")
  end
end

if __FILE__ == $0
  checker = Checker.new [ :check_length, :check_content ] 
  checker.min_length = 90000
  Babysitter.new(checker, Fetcher.new, Alerter.new).run(BabysitterSetup.url)
end

