describe "inspection of html" do
  it "fails if size is too small" do
    c = Checker.new
    (c.check "aa").should == false
  end
  it "succeeds if size is above threshold" do
    c = Checker.new
    c.check("a"*1000).should == true 
  end
  it "allows the size threshold to be changed" do
    c = Checker.new
    c.min_length = 1001
    c.check("a"*1000).should == false
  end

  it "fails if html does not contain NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content, :disable_length_check ]
    c.check("NEW DESIGN STARTS HER").should == false
  end
  it "succeeds if html contains NEW DESIGN STARTS HERE" do
    c = Checker.new [ :check_content, :disable_length_check ]
    c.check("NEW DESIGN STARTS HERE").should == true 
  end
end

class Checker
  attr_accessor :min_length

  # We are now green. I want to get rid of the c.min_length = 0 calls (in the
  # test code) as this is used as a non-intention-revealing way for disabling
  # the minimum-length check. We can do that by introducing a
  # disable_length_check flag. This is not a very good name as we want to avoid
  # negativeness in names of variables (sooner or later you'll have the double
  # negative !disable_length_check) but this is a stopgap measure which I hope
  # to replace soon.
  

  # After introducing a disable_length_check flag (instead of setting min_length
  # to zero) my goal now is to use the oppositve flag (:check_length) which has
  # a positive name and thus reduces confusion (double negative, consitent
  # semantics, etc.). We start by intorducing this flag as a defualt, although
  # no one uses it yet. I chose this path becuase all of the first three tests
  # are creating a Checker object via Cherker.new() passing no flags to the
  # ctor. My intuition tells me that I want to stay in refactoring mode (and not
  # in test-porting which is somewhat risky)
  def initialize(flags = [ :check_length ])
    @min_length = 1000
    if flags.include? :disable_length_check
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
