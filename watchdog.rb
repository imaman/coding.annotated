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

# At this point I need to decide if I want to further evolve the Checker class
# (add more tests to it). My intuition is to start expanding to the rest of the
# system. The core logic has a place (Checker) and we have a resonable interface
# for this object. It is now time to tie the things together.

# -> Decided to make the system evolve.

describe "website babysitter" do
  # As I said below, I noticed that I do not verify that the URL is passed to the
  # HTTP client, hence this new test. The problem is that I discovered that
  # while a borken test is present (the new end-to-end test introduced due to
  # the failure of tests to capture the issue of :ok/:bad not hanlded by
  # babysitter class. On top of that this test is already working. I am adding
  # it after the fact. One may think I can break the code before writing this
  # test and then write the test and make it green by fixing the delibrate
  # breakage. Sadly this will not work - we speculate that this breakage is not
  # detected by any test so the only breakage we can introduce that will trigger
  # a (Red) response is one that has massive damage and breaks other tests. This
  # means that I will be coding with multiple broken tests - not a good idea.
  #
  # I'm therefore choosing the second option - make a note to myself that the
  # end-to-end test is broken. I will introduce a break in the test (changing
  # the assertion). This will lead me to *two* breaking tests which will verify
  # that this test actually run. I will specifically make sure that the error
  # message is waht I need it be. Once this is happens, I will restore the
  # assertion to its correct value.
 it "passes the URL to the fetcher" do
    html = double("html")
    checker = double("checker").as_null_object
    http_client = double("http_client")
    # changing the assertion back to its 'correct value' after verifying that I
    # did get the error message that I wanted:
    #        Double "http_client" received :fetch with unexpected arguments
    #                 expected: ("SOME-URL__________not_the_correct_value")
    #                               got: ("SOME-URL")
    http_client.stub(:fetch).with("SOME-URL").and_return("")

    babysitter = Babysitter.new checker, http_client, double("alerter").as_null_object
    babysitter.run "SOME-URL"
  end

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

    # I managed to change the result returned by the checker to the more
    # descriptive :ok/:bad. Sadly, the tests are Green, despite the fact that
    # in the two tests below we we stub the check method such that it returns a boolean and not a :ok/:bad symbol.
    # This essentially means that a bug in the babysitter (treats the result of
    # checker as boolean and not a symbol) is not detected by our tests.
    
    # Change the stubbing from boolean to symbol (false -> :bad)
    checker.stub(:check).and_return(:bad)
    http_client = double("http_client").as_null_object
    alerter = double("alerter")
    alerter.should_receive(:alert)

    babysitter = Babysitter.new checker, http_client, alerter
    babysitter.run "SOME-URL"
  end
  it "does not fire a notification if check succeeds" do
    checker = double("checker")
    # Change the stubbing from boolean to symbol (true -> :ok)
    checker.stub(:check).and_return(:ok)
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

#Since we didn't break even when the checker changed its response to :ok/:bad,
#we add a new high-level test that simply verifies that the different pieces
#work together.

#while doing so I realized that I realized that I do not verify the URL passed
#to .run() is actually propagated to checker. 
describe "babysitter system" do
  it "works end to end" do
    # all sort of problems in the previous state of the test :( 
    # need to fix it now!

    alerter = double("alerter")
    alerter.should_receive(:alert)
    http_client = double("http_client", :fetch => "broken html")

    babysitter = Babysitter.new(Checker.new([ :check_length ]), http_client, alerter)
    babysitter.run "SOME-URL"
  end
end

class Babysitter
  def initialize(checker, http_client, alerter)
    @checker = checker
    @http_client = http_client
    @alerter = alerter
  end

  def run(url)
    # changing the code such that it works with symbols (rather than booleans)
   
    if @checker.check(@http_client.fetch(url)) == :bad
      @alerter.alert
    end
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
      return :bad
    end
    if (@flags.include? :check_content) && !html.include?("NEW DESIGN STARTS HERE")
      return :bad
    end
    return :ok
  end
end
