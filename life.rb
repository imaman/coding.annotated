describe "liveness rules" do
  it "a live cell stays live if it has two neighbors" do
    Life.next_state(true, 2).should == Life.live
  end
  it "a live cell dies if it has less than two neighbors" do
    Life.next_state(true, 1).should == Life.dead
  end
  it "a live cell stays live if it has three neighbors" do
    Life.next_state(true, 3).should == Life.live
  end
  it "a live cell dies if it has more than three neighbors" do
    Life.next_state(true, 4).should == Life.dead
  end
  it "a dead cell stays dead if it has two neighbors" do
    Life.next_state(false, 2).should == Life.dead
  end
  it "a dead cell comes back life if it has three neighbors" do
    Life.next_state(false, 3).should == Life.live
  end
end

describe "cell" do
  it "knows its neighbors" do
    Cell.new(10, 20).neighbors.should include Cell.new(9,19)
    Cell.new(10, 20).neighbors.should include Cell.new(9,20)
    Cell.new(10, 20).neighbors.should include Cell.new(9,21)
    Cell.new(10, 20).neighbors.should include Cell.new(10,19)
    Cell.new(10, 20).neighbors.should include Cell.new(10,21)
    Cell.new(10, 20).neighbors.should include Cell.new(11,19)
    Cell.new(10, 20).neighbors.should include Cell.new(11,20)
    Cell.new(10, 20).neighbors.should include Cell.new(11,21)
  end

  describe "counts living neighbors" do
    it "returns 0 when grid is empty" do
      Cell.new(100,100).live_neighbors([]).should == 0
    end
    it "returns living cells which are neighbors" do
      Cell.new(100,100).live_neighbors([ Cell.new(99,99), Cell.new(101,101)]).should == 2
    end
    it "ignores itself" do
      Cell.new(100,100).live_neighbors([ Cell.new(100,100), Cell.new(99,99), Cell.new(101,101)]).should == 2
    end
    it "ignores repeated cells" do
      Cell.new(100,100).live_neighbors([ Cell.new(99, 99), Cell.new(99,99), Cell.new(101,101)]).should == 2
    end
    it "ignores cells outside the neighborhood" do
      # I could have done instead of this example the converse:
      # "treats only cells inside the neighborhood" but that would have
      # forced me to roll out the full impl. It is usaually better
      # (due to baby-stepping) to state the restrictions, boundary conditions,
      # etc. first, and only then turn to the happy path. The implementation may
      # surface some additional edge cases so you'll have to add tests for them
      # too. Bottom line: sad, happy, sad
      Cell.new(100,100).live_neighbors([ Cell.new(0, 0), Cell.new(99,99), Cell.new(101,101)]).should == 2
    end

    it "knows if another cell and me are neighbors" do
      # In order to implement the above example "ignores cells outside the
      # neighborhood" I realized I need an "is_neightbor?" method. I faked
      # the impl. to get the above example to pass, and now I'm TDDing the
      # is_neighbor? method.
      Cell.new(5,8).is_neighbor?(Cell.new(1,2)).should == false
      Cell.new(5,8).is_neighbor?(Cell.new(5,7)).should == true 
      Cell.new(5,8).is_neighbor?(Cell.new(6,7)).should == true 
    end
 end

end

class Cell
  def initialize(x,y)
    @x = x
    @y = y
  end

  def is_neighbor?(other) 
    (other.x - x).abs <= 1 and (other.y - y).abs <= 1
  end

  def hash
    @x ^ @y
  end

  def live_neighbors(grid)
    grid.inject({}) { |r,c| 
      r[c.x.to_s + "/" + c.y.to_s] = c
      r 
    }.values.select { |x| x != self and x.x != 0 }.length
  end

  def neighbors 
    [ Cell.new(@x-1, @y-1), Cell.new(@x-1, @y), Cell.new(@x-1, @y+1), 
      Cell.new(@x, @y-1), Cell.new(@x, @y+1), 
      Cell.new(@x+1, @y-1), Cell.new(@x+1, @y), Cell.new(@x+1, @y+1) ]
  end

  def x 
    @x
  end

  def y
    @y
  end

  def ==(that)
    @x == that.x && @y == that.y
  end
end

class Dead
  def next(n)
    if n == 3 then Life.live else Life.dead end
  end
end

class Live
  def next(n) 
    if n == 2 || n == 3 then Life.live else Life.dead end
  end
end

class Life
  @@dead = Dead.new()
  @@live = Live.new()

  def self.live
    @@live
  end

  def self.dead
    @@dead
  end

  def self.next_state(is_live, n)
    # Reorganize again, this time via objects representing the state (dead or
    # alive).
    state = if is_live then live else dead end
    return state.next(n)
  end
end

