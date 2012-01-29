describe "inspection of html" do
  it "fails if size is too small" do
    c = Checker.new [ :check_length ]
    (c.check "aa").should == false
  end
  it "succeeds if size is above threshold" do
    c = Checker.new [ :check_length ]
    c.check("a"*1000).should == :ok
  end
  it "allows the size threshold to be changed" do
    c = Checker.new [ :check_length ]
    c.min_length = 1001
    c.check("a"*1000).should == false
  end

  it "fails if html does not contain NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content ]
    c.check("NEW DESIGN STARTS HER").should == false
  end
  it "succeeds if html contains NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content ]
    c.check("NEW DESIGN STARTS HERE").should == :ok
  end
end

# At this point I need to decide if I want to further evolve the Checker class
# (add more tests to it). My intuition is to start expanding to the rest of the
# system. The core logic has a place (Checker) and we have a resonable interface
# for this object. It is now time to tie the things together.

# -> Decided to make the system evolve.

describe "website babysitter" do
  it "fetches html content and passes it to the checker" do
    html = double("html")
    checker = double("checker")
    checker.stub(:check).with(html).and_return(true)
    http_client = double("http_client", :fetch => html)

    babysitter = Babysitter.new checker, http_client, double("alerter").as_null_object
    babysitter.run "SOME-URL"
  end

  # So the checker returns true/false to the babysitter. Should the babysitter
  # pass this value to the "alerter" object (and let the alerter decide whether
  # an alert should be fired)? Or - otherwise - the babysitter will examine the
  # result returned from the checker and call alerter.alert() if its false. 
  #
  # These is a design decision which pertains to the boundary of
  # responsibilities between the objects. As babysitter seems to be a fairly
  # simple object, I prefer to put this responsibility in his hands.
  it "fires notification if check failed" do
    checker = double("checker")
    checker.stub(:check).and_return(false)
    http_client = double("http_client").as_null_object
    alerter = double("alerter")
    alerter.should_receive(:alert)

    babysitter = Babysitter.new checker, http_client, alerter
    babysitter.run "SOME-URL"
  end
  it "does not fire a notification if check succeeds" do
    checker = double("checker")
    checker.stub(:check).and_return(true)
    http_client = double("http_client").as_null_object
    alerter = double("alerter")

    babysitter = Babysitter.new checker, http_client, double("alerter")
    babysitter.run "SOME-URL"
  end

  # The recent confusion with the stubbed value checker.check (and a similar
  # mixup with the if at Babysitter.run (I initially did alerter.alert if
  # @checker... - missed the negation) made me think that a boolean value is not
  # a good fit. We (humans) are conditioned to associate an action with a truth
  # value. Here we use true to say "passed the check" - which makes sense (b/c
  # we also associate truth with "good"). The solution is to use dedicated
  # values: ":ok", ":bad"
end

class Babysitter
  def initialize(checker, http_client, alerter)
    @checker = checker
    @http_client = http_client
    @alerter = alerter
  end

  def run(url)
    @alerter.alert if !@checker.check(@http_client.fetch(url))
  end
end

class Checker
  # I don't like this attr_accessor too much. I'd rather pass it as a parameter
  # to the ctor (an 'options' hash or something). However, this may be
  # over-verbosity for the boolean flags so I'm keeping it as-is for now.
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
      return false
    end
    if (@flags.include? :check_content) && !html.include?("NEW DESIGN STARTS HERE")
      return false
    end
    return :ok
  end
end
