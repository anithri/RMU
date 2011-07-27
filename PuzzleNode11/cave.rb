#@author Scott M Parrish<anithri@gmail.com>
# Creates an object that contains a cave representation, and uses a cursor and basic rules to simulate the flow of
# water into the cave.

class Cave

  #Error class to raise
  class CaveError < StandardError
  end

  #constants to make cursor movement more clear
  UPWARD = LEFT = -1
  DOWN = RIGHT = 1
  SAME = 0

  #cave contains the the array of equal length strings that makes up the cave picture
  attr_reader :cave

  # @param [Array<String>] # array from file containing equal length strings
  # TODO check input lengths and string composition to catch malformed cave pictures
  def initialize(cave)
    @cave = cave.map(&:chomp)
    raise CaveError.new("cave contains invalid characters") unless cave_is_valid?
    @width = @cave[0].length
    #set the initial cursor values to the location space and save that position in the 2 cursor
    @cursor_row = @cave.find_index{|l| @cursor_col = l.rindex("~");!@cursor_col.nil? }
  end

  #add water to the cave.
  # @param [Fixnum] num is the number of units of water to add to the system
  def flow(num = 1)
    begin
      num.times do
        add_water if next_open
      end
    rescue CaveError => e
      raise e
    end
  end

  # returns an array of the depths of water found in the cave currently.
  # @return [Array<Fixnum,String>]
  def depths
    all = []
    @width.times do |i|
      #make a string out of the same col of every row.  Up will be on the left.
      d = @cave.collect{|l| l[i]}.join("")

      #if there is a ~ followed by a space, then we report ~ instead of a depth.
      if d.include?("~ ")
        all << "~"
      #count 0 if there are no ~
      elsif !d.include?("~")
        all << 0
      #find the index of the first and last ~, and add 1 for inclusiveness
      else
        a = d.rindex("~") - d.index("~") + 1
        all << a
      end
    end
    all
  end

  private

  #check the cave for invalid characters
  #@return [Boolean] 
  def cave_is_valid?
    @cave.none?{|l| l =~ /[^ #~]/}
  end


  #return the character at the current cursor position
  # @return [String] the character
  def current
    @cave[@cursor_row][@cursor_col]
  end

  # mark the current space as water, but raise an exception if it's not an open space.
  def add_water
    raise CaveError.new unless current == " "
    @cave[@cursor_row][@cursor_col] = "~"
  end

  #move the cursor to the next space where water can go.
  def next_open
    #If the space below, or to the right of the cursor, is open then move there
    return @cursor_row += DOWN if look_at(DOWN,SAME) == " "
    return @cursor_col += RIGHT if look_at(SAME, RIGHT) == " "

    #repeat moving the cursor up and scanning right for open space until we run out of room or find one
    until current == " " || @cursor_col.nil?
      @cursor_row += UPWARD
      # this_row     = @cave[@cursor_row] #get the current row
      # start_string = this_row[0..@cursor_col] #get the start of the row up to the current cursor col
      # @cursor_col = start_string.index(/\s+/)) #look for the col of the leftmost space in the last section of open space. returns nil if it doesn't find one.
      @cursor_col = @cave[@cursor_row][0..@cursor_col].index(/\s+$/)
    end
    #if this spot is open return true otherwise false.
    return true if current == " "
    false
  end

  #adjust the cursor position temporarily and return the character found there.
  def look_at(row_adjust, col_adjust)
    @cave[@cursor_row + row_adjust][@cursor_col + col_adjust ]
  end

end
