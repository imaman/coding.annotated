describe "liveness rules" do
  it "a live cell stays live if it has two neighbors" do
    Life.next_state(true, 2).should == true
  end
  it "a live cell dies if it has less than two neighbors" do
    Life.next_state(true, 1).should == false
  end
  it "a live cell stays live if it has three neighbors" do
    Life.next_state(true, 3).should == true
  end
  it "a live cell dies if it has more than three neighbors" do
    Life.next_state(true, 4).should == false
  end
  it "a dead cell stays dead if it has two neighbors" do
    Life.next_state(false, 2).should == false
  end
  it "a dead cell comes back life if it has three neighbors" do
    Life.next_state(false, 3).should == true
  end
end


class Life
  def self.next_state(is_live, n)
    # Now let's reorganize the rules by n
    return true if n == 3
    return n == 2 && is_live
  end
end

