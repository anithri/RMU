#@author Scott M Parrish<anithri@gmail.com>
# Creates an object given a circuit map, and provides a method for determining it's value
# by recursively creating new objects for each input for the logic gate
# The current place in the circuit is marked by @cursor, and is moved around following the circuit path
class Circuit
  #constants to make reading the cursor adjustments easier
  UPWARD = LEFT = -1
  DOWN = RIGHT = 1
  SAME = 0

  #used to turn the logic gates into symbols for the appropriate method
  OPERAND = {"O" => :|, "X" => :^, "A" => :&}

  #All the valid characters except the gates and values
  NAVIGATION_CHARS = " -|@\n"
  #all of the valid values and gates
  OPERAND_CHARS = "01AONX"

   #Error class to raise
  class CircuitError < StandardError
  end

  #a simple structure to keep track of the curor location
  Cursor = Struct.new(:row, :col)

  # Create a new Object,
  # @param [Array<String>] circuit the circuit to analyze
  # @param [Cursor] start_cursor (nil) the cursor starting location.
  def initialize(circuit, start_cursor = nil)
    #guard clause to catch incomplete calls.
    raise ArgumentError.new("start_cursor must be a valid cursor") if start_cursor  &&  (start_cursor.col.nil? || start_cursor.row.nil?)
    #this is the object attribute used to hold the circuit in.  Frozen to prevent modification
    @circuit = circuit.freeze
    #no start_row is given for the initial object. Call find_start in that case, save the starting cursor if not.
    if start_cursor.nil?
      find_start
    else
      @start_address = start_cursor.dup
      @cursor        = start_cursor.dup
    end
  end

  # determine the boolean value of the input values and result of logic gate
  # @return [Boolean]  resulting value of logic gate and inputs
  def find_value
    #Guard clause to handle incorrect characters
    raise ArgumentError unless (NAVIGATION_CHARS + OPERAND_CHARS).include?(current)
    raise Exception.new("Not on an operand at line:#{@cursor.row}, column:#{@cursor.col} [#{current}]") unless OPERAND_CHARS.include?(current)

    #returns for specific values
    return false if current == "0"
    return true  if current == "1"

    #Get the circuit from the upward direction.
    @up_val = fetch_vertical(UPWARD)

    #return the NOT value (which is unary and doesn't need the down input')
    return handle_not_operand if current == "N"

    #fetch the circuit from the down direction
    @down_val = fetch_vertical(DOWN)
    #Based on the return and guard clauses above, the only remaining values are AOX
    #find the value of the UP circuit, and pass it the methiod name and value of the DOWN circuit and implicitly return
    @up_val.find_value.send(OPERAND[current],@down_val.find_value)
  end

  private
  # Scan for the "@" symbol in the circuit, and follow the result to the initial Logic Gate
  def find_start
    row = @circuit.find_index { |line| line.end_with?("@\n")}
    raise CircuitError.new("No @ found for circuit.") if row.nil?
    col = @circuit[row].length - 2 #correct for 0 array and \n
    @cursor = Cursor.new(row,col)
    jump_left
    @start_address = @cursor.dup
  end

  #return the value of the unary NOT
  # @return [Boolean]
  def handle_not_operand
    return ! @up_val.find_value
  end

  #given a offset, return the character at the cursor modified by the offset.
  # @return [String] a single character
  def look_at(row_adjust,col_adjust)
    @circuit[@cursor.row + row_adjust][@cursor.col + col_adjust]
  end

  #show the character at the current cursor location
  # @return [String] a single character
  def current
    @circuit[@cursor.row][@cursor.col]
  end

  # follow the circuit in the given direction to the next logic gate, create a Circuit object for that gate,
  #   After it has traced the path, reset the cursor back to the starting gate
  # @param [FIXNUM] dir the direction (UP/DOWN) to follow the circuit in
  def fetch_vertical(dir)
    jump_vertical(dir)
    return nil if @cursor == @start_address
    coords = @cursor.dup
    @cursor = @start_address.dup
    Circuit.new(@circuit, coords)
  end

  # follow "|" characters until it turns, then call jump_left
  # @param [FIXNUM] dir the direction (UP/DOWN) to follow the circuit in
  def jump_vertical(direction)
    while check_for("|",direction,SAME) do
      @cursor.row += direction
    end
    jump_left
  end

  # follow the "-" character until you get run out of them, then move the cursor 1 more to the left
  # which should be (given a valid circuit) one of the OPERAND characters
  def jump_left
    while check_for("-",SAME,LEFT) do
      @cursor.col += LEFT
    end
    @cursor.col += LEFT
  end

  # determine if a certain character is present at an offset of the cursor.
  # always fails if the adjustment would be outside of the array or string
  # @return [Boolean] does the character match?
  def check_for(char, row_adjust, col_adjust)
    new_row = @cursor.row + row_adjust
    new_col = @cursor.col + col_adjust
    return false if new_row < 0 || new_row >= @circuit.length
    return false if new_col < 0 || new_col >= @circuit[new_row].length
    look_at(row_adjust,col_adjust) == char
  end

end
