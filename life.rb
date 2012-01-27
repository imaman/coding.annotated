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

    it "ignores cells outside neighborhood even if they are very close" do
      # after implementing is_neighbor I can get back to the "live_neighbor"
      # method which is currently faked.
      
      Cell.new(100,100).live_neighbors([ Cell.new(98, 100), Cell.new(99,99), Cell.new(101,101)]).should == 2
    end
  end

  describe "computes next state" do
    #now I feel the burden of combinatorial explosion. I have already tested
    #the liveness logic, and the number of living neighbors logic. The
    #next_state method should simply wire-up these two logics. I can't (at this
    #point) think of a baby-step test - all I can think of is a test that checks
    #the whole thing which means cross product of liveness and living_neighbors.
    #the only plusible solution is to use mocking.
    
    #A-ha! If I can't find a (non-combinatorial) test for it then this behavior
    #should probably move someplace else - it indicates that my Cell class is
    #doing too much.
  end
end

describe "step forward logic" do
  it "takes a grid a cell and a state and produces the next state for that cell" do
    c1 = Cell.new(0,0)
    c2 = Cell.new(0,0)
    c3 = Cell.new(0,0)
    grid = [ c1, c2, c3 ];
    state = Life.live

    # I realize that I probably want the Life class to be non-static.
    # Life.next_state() is not a good method - it takes a boolean where I want
    # to use the "Dead/Live" terminology. So, I come up with new function:
    # step() - take a cell and grid. Determines current state by checking
    # existence of the cell inside the grid. Then computes number of neighbors
    # and passes it to the state.
    #


    # This one took a lot of time. I couldn't wrap my head around it.
    # Eventually, I decided the best way would be to implement the impl. in the
    # test! get the test to work and then move it to the application code.
    # That's a common trick for overcoming blindness , esp. when mocking is
    # involved.
    #
    s = stub('state')
    s.should_receive(:next_state).with(5000)
    c = stub('cell', :state_in => s, :living_neighbors => 5000)

    state = c.state_in(grid)
    state.next_state(c.living_neighbors(grid))
  end
end


class Cell
  def initialize(x,y)
    @x = x
    @y = y
  end

  def state_in(grid)
    raise "not implemented yet!" # this method was added and stubbed. I'm a adding a place holder to make sure I don't forget to impl. it.
  end

  def is_neighbor?(other) 
    self != other and (other.x - x).abs <= 1 and (other.y - y).abs <= 1
  end

  def hash
    @x ^ @y
  end

  def live_neighbors(grid)
    grid.inject({}) { |r,c| 
      r[c.x.to_s + "/" + c.y.to_s] = c
      r 
    }.values.select { |x| is_neighbor?(x) }.length
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

