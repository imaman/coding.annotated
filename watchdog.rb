describe "inspection of html" do
  it "fails if size is too small" do
    c = Checker.new [ :check_length ]
    (c.check "aa").should == :bad
  end
  it "succeeds if size is above threshold" do
    c = Checker.new [ :check_length ]
    c.check("a"*1000).should == :ok
  end
  it "allows the size threshold to be changed" do
    c = Checker.new [ :check_length ]
    c.min_length = 1001
    c.check("a"*1000).should == :bad
  end

  it "fails if html does not contain NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content ]
    c.check("NEW DESIGN STARTS HER").should == :bad
  end
  it "succeeds if html contains NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content ]
    c.check("NEW DESIGN STARTS HERE").should == :ok
  end
end

describe "website babysitter" do
  it "passes the URL to the fetcher" do
    checker = double("checker").as_null_object
    http_client = double("http_client")
    http_client.stub(:fetch).with("SOME-URL").and_return("")

    babysitter = Babysitter.new checker, http_client, double().as_null_object
    babysitter.run "SOME-URL"
  end

  it "fetches html content and passes it to the checker" do
    html = double("html")
    checker = double("checker")
    checker.stub(:check).with(html).and_return(true)
    http_client = double("http_client", :fetch => html)

    babysitter = Babysitter.new checker, http_client, double().as_null_object
    babysitter.run ""
  end

  it "fires notification if check failed" do
    checker = double("checker")

    checker.stub(:check).and_return(:bad)
    http_client = double("http_client").as_null_object
    alerter = double("alerter")
    alerter.should_receive(:alert)

    babysitter = Babysitter.new checker, http_client, alerter
    babysitter.run ""
  end

  it "does not fire a notification if check succeeds" do
    checker = double("checker")
    checker.stub(:check).and_return(:ok)
    http_client = double("http_client").as_null_object

    # Here I do *not* want to change the alerter to null_object!
    # This test asserts that nothing is called on alerter. If it were a null
    # object the test would not fail. That's the reason why it is named. If 
    # this were unnamed the error message produced by this code is:
    #   1) website babysitter does not fire a notification if check succeeds
    #        Failure/Error: @alerter.alert
    #               Double received unexpected message :alert with (no args)
    #                    # ./watchdog.rb:105:in `run'
    #                         # ./watchdog.rb:69
    # OTOH, when this double is named we get
    #   1) website babysitter does not fire a notification if check succeeds
    #        Failure/Error: @alerter.alert
    #               Double "alerter" received unexpected message :alert with (no
    #               args)
    #                    # ./watchdog.rb:109:in `run'
    #                         # ./watchdog.rb:73
    # 
    # Note the "Dobule received" vs. "Double "alerter" received". The latter is
    # easier to read.
    babysitter = Babysitter.new checker, http_client, double("alerter")
    babysitter.run ""
  end
end

describe "babysitter system" do
  it "works end to end" do
    # although it is end-to-end we can't do much with alerter and http_client -
    # both of them talk to external world and we need somehow to fake them (we
    # do not want the test to send a real e-mail) thus we do have stubbing even
    # in this end-to-end test. Actually, the code is quite simple so other than
    # these two classes, the only one that is really "our code" (not wrapper
    # around external services) is Checker. Indeed, we do instantiate this class
    # and use its "real" implementation.
    alerter = double("alerter")
    alerter.should_receive(:alert)
    http_client = double("http_client", :fetch => "")

    babysitter = Babysitter.new(Checker.new([ :check_length ]), http_client, alerter)
    babysitter.run ""
  end
end

class Babysitter
  def initialize(checker, http_client, alerter)
    @checker = checker
    @http_client = http_client
    @alerter = alerter
  end

  def run(url)
    # Something to think about: do I want to enforce the use of :ok/:bad?
    # currently it recognized :bad and everything other than :bad is considered
    # to 'ok'.
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
