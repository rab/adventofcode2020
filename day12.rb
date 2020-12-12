# --- Day 12: Rain Risk ---
#
# Your ferry made decent progress toward the island, but the storm came in faster than anyone
# expected. The ferry needs to take evasive actions!
#
# Unfortunately, the ship's navigation computer seems to be malfunctioning; rather than giving a
# route directly to safety, it produced extremely circuitous instructions. When the captain uses
# the PA system to ask if anyone can help, you quickly volunteer.
#
# The navigation instructions (your puzzle input) consists of a sequence of single-character
# actions paired with integer input values. After staring at them for a few minutes, you work out
# what they probably mean:
#
# Action N means to move north by the given value.
# Action S means to move south by the given value.
# Action E means to move east by the given value.
# Action W means to move west by the given value.
# Action L means to turn left the given number of degrees.
# Action R means to turn right the given number of degrees.
# Action F means to move forward by the given value in the direction the ship is currently facing.
#
# The ship starts by facing east. Only the L and R actions change the direction the ship is
# facing. (That is, if the ship is facing east and the next instruction is N10, the ship would
# move north 10 units, but would still move east if the following action were F.)
#
# For example:
#
# F10
# N3
# F7
# R90
# F11
#
# These instructions would be handled as follows:
#
# F10 would move the ship 10 units east (because the ship starts by facing east) to east 10, north 0.
# N3 would move the ship 3 units north to east 10, north 3.
# F7 would move the ship another 7 units east (because the ship is still facing east) to east 17,
#    north 3.
# R90 would cause the ship to turn right by 90 degrees and face south; it remains at east 17, north 3.
# F11 would move the ship 11 units south to east 17, south 8.
#
# At the end of these instructions, the ship's Manhattan distance (sum of the absolute values of
# its east/west position and its north/south position) from its starting position is 17 + 8 = 25.
#
# Figure out where the navigation instructions lead. What is the Manhattan distance between that
# location and the ship's starting position?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2020)

while ARGV[0]
  case ARGV.shift
  when 'test'
    $testing = true
  when 'debug'
    $debugging = true
  end
end

if $testing
  input = <<~END
F10
N3
F7
R90
F11
  END
else
  puts "solving day #{day} from input"
end

class Ship
  attr_accessor :dir, :east, :north

  def initialize
    @dir = 'E'
    @east, @north = 0, 0
  end

  def execute(cmd)
    action, value = /\A([NSEWRLF])(\d+)\z/.match(cmd).captures
    value = value.to_i
    puts "#{cmd} => #{action.inspect}, #{value.inspect}" if $debugging
    case action
    when 'N','E','S','W'
      move action, value
    when 'F'
      move @dir, value
    when 'L','R'
      turn action, value
    else
      fail "Unknown action #{cmd}"
    end
  end

  private def move(cardinal, distance)
    case cardinal
    when 'N'
      @north += distance
    when 'E'
      @east += distance
    when 'S'
      @north -= distance
    when 'W'
      @east -= distance
    end
  end

  private def turn(which, amount)
    @dir = case which
           when 'R'
             { 'E' => { 0 => 'E',
                        90 => 'S',
                        180 => 'W',
                        270 => 'N',
                      },
               'S' => { 0 => 'S',
                        90 => 'W',
                        180 => 'N',
                        270 => 'E',
                      },
               'W' => { 0 => 'W',
                        90 => 'N',
                        180 => 'E',
                        270 => 'S',
                      },
               'N' => { 0 => 'N',
                        90 => 'E',
                        180 => 'S',
                        270 => 'W',
                      },
             }
           when 'L'
             { 'E' => { 0 => 'E',
                        90 => 'N',
                        180 => 'W',
                        270 => 'S',
                      },
               'S' => { 0 => 'S',
                        90 => 'E',
                        180 => 'N',
                        270 => 'W',
                      },
               'W' => { 0 => 'W',
                        90 => 'S',
                        180 => 'E',
                        270 => 'N',
                      },
               'N' => { 0 => 'N',
                        90 => 'W',
                        180 => 'S',
                        270 => 'E',
                      },
             }
           end[@dir][amount]
    fail "Bad turn? #{which.inspect}, #{amount}" unless @dir
  end

  def manhattan
    @east.abs + @north.abs
  end
end

ship = Ship.new

input.each_line(chomp: true) do |line|
  ship.execute line
end

part1 = ship.manhattan
puts "Part 1:", part1
expected = 25
fail "Expected #{expected}, but got #{part1}" if $testing && expected != part1


# --- Part Two ---

# Before you can give the destination to the captain, you realize that the actual action meanings
# were printed on the back of the instructions the whole time.

# Almost all of the actions indicate how to move a waypoint which is relative to the ship's
# position:

# Action N means to move the waypoint north by the given value.
# Action S means to move the waypoint south by the given value.
# Action E means to move the waypoint east by the given value.
# Action W means to move the waypoint west by the given value.
# Action L means to rotate the waypoint around the ship left (counter-clockwise) the given number of degrees.
# Action R means to rotate the waypoint around the ship right (clockwise) the given number of degrees.
# Action F means to move forward to the waypoint a number of times equal to the given value.

# The waypoint starts 10 units east and 1 unit north relative to the ship. The waypoint is
# relative to the ship; that is, if the ship moves, the waypoint moves with it.

# For example, using the same instructions as above:

# F10 moves the ship to the waypoint 10 times (a total of 100 units east and 10 units north),
# leaving the ship at east 100, north 10. The waypoint stays 10 units east and 1 unit north of the
# ship.

# N3 moves the waypoint 3 units north to 10 units east and 4 units north of the ship. The ship
# remains at east 100, north 10.

# F7 moves the ship to the waypoint 7 times (a total of 70 units east and 28 units north), leaving
# the ship at east 170, north 38. The waypoint stays 10 units east and 4 units north of the ship.

# R90 rotates the waypoint around the ship clockwise 90 degrees, moving it to 4 units east and 10
# units south of the ship. The ship remains at east 170, north 38.

# F11 moves the ship to the waypoint 11 times (a total of 44 units east and 110 units south),
# leaving the ship at east 214, south 72. The waypoint stays 4 units east and 10 units south of
# the ship.

# After these operations, the ship's Manhattan distance from its starting position is 214 + 72 =
# 286.

# Figure out where the navigation instructions actually lead. What is the Manhattan distance
# between that location and the ship's starting position?

class Waypoint
  attr_accessor :w_east, :w_north

  def initialize
    @ship = Ship.new
    @w_east = 10
    @w_north = 1
  end

  def wexec(cmd)
    action, value = /\A([NSEWRLF])(\d+)\z/.match(cmd).captures
    value = value.to_i
    puts "#{cmd} => #{action.inspect}, #{value.inspect}" if $debugging
    case action
    when 'N','E','S','W'
      wmove action, value
    when 'F'
      if @w_north.positive?
        @ship.execute("N#{value * @w_north}")
      else
        @ship.execute("S#{- value * @w_north}")
      end
      if @w_east.positive?
        @ship.execute("E#{value * @w_east}")
      else
        @ship.execute("W#{- value * @w_east}")
      end
    when 'L','R'
      rotate action, value
    else
      fail "Unknown action #{cmd}"
    end
  end

   private def wmove(cardinal, distance)
    case cardinal
    when 'N'
      @w_north += distance
    when 'E'
      @w_east += distance
    when 'S'
      @w_north -= distance
    when 'W'
      @w_east -= distance
    end
  end

  private def rotate(which, amount)
    while amount.positive?
      case which
      when 'R'
        @w_east, @w_north = @w_north, -@w_east
      when 'L'
        @w_east, @w_north = -@w_north, @w_east
      end
      amount -= 90

      fail "Too much!" if amount.negative?
    end
  end

  def manhattan
    @ship.manhattan
  end

end

puts

ship = Waypoint.new

input.each_line(chomp: true) do |line|
  ship.wexec line
end

part2 = ship.manhattan
puts "Part 2:", part2
expected = 286
fail "Expected #{expected}, but got #{part2}" if $testing && expected != part2
