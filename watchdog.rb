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
    c = Checker.new [ :check_content ]
    c.check("NEW DESIGN STARTS HERE").should == true 
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
  def initialize(flags = [])
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
