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
  end

end

class Cell
  def initialize(x,y)
    @x = x
    @y = y
  end

  def live_neighbors(grid)
    grid.length
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

