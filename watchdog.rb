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
    c.min_length = 0
    # I chose almost the string that I'm searching for but 
    # I omitted the last 'E'. This is needed to make sure that even content that
    # are quite close to the string that I'm interested in will not be
    # addmitted.
    c.check("NEW DESIGN STARTS HER").should == false
  end
  # I now want to refactor the check_content! method into a bag-of-flags
  # that will be passed to the constructor, as in: Checker.new [:check_content]
  # How do I do that?
  # If start working on the happy path ('succeeds if html contains...') I will
  # get green even if my refacotring is buggy: suppose I mis-implement the
  # bag-of-flags logic and that it does *not* activates content checking. The
  # only check that will be applied is the min_length but this check is
  # configured with 0 which effectively disables it. Thus, a green result after
  # the refactoring will be meaningless.
  #
  # Of course - I can try to refactor all test methods at once buts that's a
  # giant leap which is not always fesible and is largely discouraged. 
  #
  # The solution: 
  # Step 1 - change the Sad test's code (above "fails if html does not") - to
  # use the new API. The test will go Red b/c the check will be of so the result
  # returned by the checker will be positive.
  #
  # Step 2 - Make the Sad test pass - implement the new API (in parallel to the
  # old API). Now all tests should be green.
  #
  # Step 3 - Remove the old API. This will break the happy test.
  #
  # Step 4 - Port the happy test to use the new API.
  it "succeeds if html contains NEW DESIGN STARTS HERE" do
    # we are now in a subtle position: this test is red due to undefined method
    # (we just removed check_content!). Ideally we want it now to fail on the
    # assertion. this is not so easy to achieve. If we just remove the
    # c.check_content! line (causing the undefined method problem) the test will
    # fully pass, even though we didn't move its code to use the new API. That's
    # because it is a happy test so it is neutral to checks that are disabled.
    #
    

    c = Checker.new
    c.min_length = 0
    # We are now Green despite the fact the porting was not correct. This was
    # not a surprise - the last failure was not the failure that we wanted. So
    # we managed to get to Green without really solving the underlying problem.
    # In such cases, the best thing to do is to intentionally change the test
    # into a sad one. This will surface the problem of the the incorrect
    # porting.
    c.check("illegal input").should == false
  end
end

class Checker
  attr_accessor :min_length
  

  # The sad test is broken but for the wrong reason:
  # Failure/Error: c =
  # Checker.new [ :check_content ]
  #      ArgumentError:
  #             wrong number of arguments (1 for 0)
  #
  # We want it to fail due to wrong answer (true instead false).
  # To do that we need to add the new param to the ctor. We need to make this an
  # optional param (otherwise, all other tests will break). Once we do that
  # we'll get the error message that we want, which will allow us to move
  # further to making the test Green.
  def initialize(flags = [])
    @min_length = 1000
    @check_content = flags.include? :check_content
  end

  # Step 3: we now want to get rid of the old API. Simply by removing the
  # check_content! method. this will give us the failure that we need: 
  # 'undefined method `check_content!' for ...' in the happy test

  def check(html)
    html.length >= min_length && (!@check_content || html.include?("NEW DESIGN STARTS HERE"))
  end
end
