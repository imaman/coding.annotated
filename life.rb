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
    # At this point, the rules are organized by the current state of the cell
    if is_live
      n == 2 || n == 3
    else
      n == 3
    end
  end
end

