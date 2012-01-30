require 'watchdog'

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
    null = double().as_null_object  

    http_client = double("http_client")
    babysitter = Babysitter.new(null, http_client, null)

    http_client.should_receive(:fetch).with("SOME-URL").and_return("")
    babysitter.run "SOME-URL"
  end

  it "fetches html content and passes it to the checker(*)" do
    checker = double("checker")

    http_client = double("http_client", :fetch => "HTML-THAT-WAS-FETCHED")
    checker.should_receive(:check).with("HTML-THAT-WAS-FETCHED")

    Babysitter.new(checker, http_client, double().as_null_object).run ""
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

    babysitter = Babysitter.new checker, http_client, double("alerter")
    babysitter.run ""
  end
end

describe "babysitter system" do
  it "works end to end" do
    alerter = double("alerter")
    alerter.should_receive(:alert)
    http_client = double("http_client", :fetch => "")

    babysitter = Babysitter.new(Checker.new([ :check_length ]), http_client, alerter)
    babysitter.run ""
  end
end
