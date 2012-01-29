describe "inspection of html" do
  it "fails if size is too small" do
    c = Checker.new [ :check_length ]
    (c.check "aa").should == false
  end
  it "succeeds if size is above threshold" do
    c = Checker.new [ :check_length ]
    c.check("a"*1000).should == true 
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
    c.check("NEW DESIGN STARTS HERE").should == true 
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
    babysitter = Babysitter.new checker, http_client
    babysitter.run "SOME-URL"
 end
end

class Babysitter
  def initialize(checker, http_client)
    @checker = checker
    @http_client = http_client
  end

  def run(url)
    @checker.check(@http_client.fetch(url))
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
    return true
  end
end
