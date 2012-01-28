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
    c = Checker.new
    c.min_length = 0
    c.check_content!
    c.check("NEW DESIGN STARTS HER").should == false
  end
  it "succeeds if html contains NEW DESIGN STARTS HERE" do
    c = Checker.new
    c.min_length = 0
    c.check_content!
    c.check("NEW DESIGN STARTS HERE").should == true
  end
end

class Checker
  attr_accessor :min_length
  

  def initialize
    @min_length = 1000
    @check_content = false
  end

  def check_content!
    @check_content = true
  end

  def check(html)
    html.length >= min_length && (!@check_content || html.include?("NEW DESIGN STARTS HERE"))
  end
end
