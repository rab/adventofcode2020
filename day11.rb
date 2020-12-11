# --- Day 11: Seating System ---

# Your plane lands with plenty of time to spare. The final leg of your journey is a ferry that
# goes directly to the tropical island where you can finally start your vacation. As you reach the
# waiting area to board the ferry, you realize you're so early, nobody else has even arrived yet!
#
# By modeling the process people use to choose (or abandon) their seat in the waiting area, you're
# pretty sure you can predict the best place to sit. You make a quick map of the seat layout (your
# puzzle input).
#
# The seat layout fits neatly on a grid. Each position is either floor (.), an empty seat (L), or
# an occupied seat (#). For example, the initial seat layout might look like this:
#
# L.LL.LL.LL
# LLLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....
# LLLLLLLLLL
# L.LLLLLL.L
# L.LLLLL.LL
#
# Now, you just need to model the people who will be arriving shortly. Fortunately, people are
# entirely predictable and always follow a simple set of rules. All decisions are based on the
# number of occupied seats adjacent to a given seat (one of the eight positions immediately up,
# down, left, right, or diagonal from the seat). The following rules are applied to every seat
# simultaneously:
#
#
# If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
# If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
# Otherwise, the seat's state does not change.
#
# Floor (.) never changes; seats don't move, and nobody sits on the floor.
#
# After one round of these rules, every seat in the example layout becomes occupied:
#
# #.##.##.##
# #######.##
# #.#.#..#..
# ####.##.##
# #.##.##.##
# #.#####.##
# ..#.#.....
# ##########
# #.######.#
# #.#####.##
#
# After a second round, the seats with four or more occupied adjacent seats become empty again:
#
# #.LL.L#.##
# #LLLLLL.L#
# L.L.L..L..
# #LLL.LL.L#
# #.LL.LL.LL
# #.LLLL#.##
# ..L.L.....
# #LLLLLLLL#
# #.LLLLLL.L
# #.#LLLL.##
#
# This process continues for three more rounds:
#
# #.##.L#.##
# #L###LL.L#
# L.#.#..#..
# #L##.##.L#
# #.##.LL.LL
# #.###L#.##
# ..#.#.....
# #L######L#
# #.LL###L.L
# #.#L###.##
#
# #.#L.L#.##
# #LLL#LL.L#
# L.L.L..#..
# #LLL.##.L#
# #.LL.LL.LL
# #.LL#L#.##
# ..L.L.....
# #L#LLLL#L#
# #.LLLLLL.L
# #.#L#L#.##
#
# #.#L.L#.##
# #LLL#LL.L#
# L.#.L..#..
# #L##.##.L#
# #.#L.LL.LL
# #.#L#L#.##
# ..L.L.....
# #L#L##L#L#
# #.LLLLLL.L
# #.#L#L#.##
#
# At this point, something interesting happens: the chaos stabilizes and further applications of
# these rules cause no seats to change state! Once people stop moving around, you count 37
# occupied seats.
#
# Simulate your seating area by applying the seating rules repeatedly until no seats change
# state. How many seats end up occupied?
#

require_relative 'input'

day = __FILE__[/\d+/].to_i(10)
input = Input.for_day(day, 2020)

while ARGV[0]
  case ARGV.shift
  when 'test'
    testing = true
  when 'debug'
    debugging = true
  end
end

if testing
  input = <<~END
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
  END
else
  puts "solving day #{day} from input"
end

class Grid
  def initialize(content)
    @grid = content.split.map{|_|_.split(//)}
  end

  FLOOR='.'
  EMPTY='L'
  FULL='#'
  EMPTYING='^'
  FILLING='v'
  OCCUPIED = [FULL, EMPTYING].join
  private def neighbors(row_index, cell_index)
    rows, cols = self.size
    cells = 0
    if row_index > 0
      row = @grid[row_index-1]
      cells += row[[0,cell_index-1].max .. [cols-1,cell_index+1].min].join.count(OCCUPIED)
    end
    cells += @grid[row_index][cell_index-1].count(OCCUPIED) if cell_index > 0
    cells += @grid[row_index][cell_index+1].count(OCCUPIED) if cell_index < cols-1
    if row_index < rows-1
      row = @grid[row_index+1]
      cells += row[[0,cell_index-1].max .. [cols-1,cell_index+1].min].join.count(OCCUPIED)
    end
    cells
  end

  # Now, instead of considering just the eight immediately adjacent seats, consider the first seat
  # in each of those eight directions. For example, the empty seat below would see eight occupied
  # seats:
  private def sightline(row_index, col_index)
    rows, cols = self.size
    cells = 0
    # in each of the eight cardinal directions …
    {
      'N'  => [-1, 0],
      'NE' => [-1, 1],
      'E'  => [ 0, 1],
      'SE' => [ 1, 1],
      'S'  => [ 1, 0],
      'SW' => [ 1,-1],
      'W'  => [ 0,-1],
      'NW' => [-1,-1],
    }.each do |dir,(drow,dcol)|
      row, col = row_index, col_index
      begin
        row += drow
        col += dcol
      end while (0...rows).cover?(row) && (0...cols).cover?(col) && @grid[row][col] == FLOOR
      next unless (0...rows).cover?(row) && (0...cols).cover?(col)
      cells += 1 if OCCUPIED.include? @grid[row][col]
    end
    cells
  end

  def cycle(rule: :adjacent)
    @grid.each.with_index do |row, row_index|
      row.each.with_index do |cell, cell_index|
        case rule

        # If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
        # If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
        # Otherwise, the seat's state does not change.
        when :adjacent
          cell.replace cell.tr([EMPTY,   FULL].join,
                               [[FILLING,FULL].join,    # 0
                                [EMPTY,  FULL].join,     # 1
                                [EMPTY,  FULL].join,     # 2
                                [EMPTY,  FULL].join,     # 3
                                [EMPTY,  EMPTYING].join, # 4
                                [EMPTY,  EMPTYING].join, # 5
                                [EMPTY,  EMPTYING].join, # 6
                                [EMPTY,  EMPTYING].join, # 7
                                [EMPTY,  EMPTYING].join, # 8
                               ][neighbors(row_index, cell_index)])


        # Also, people seem to be more tolerant than you expected: it now takes five or more visible
        # occupied seats for an occupied seat to become empty (rather than four or more from the previous
        # rules). The other rules still apply: empty seats that see no occupied seats become occupied,
        # seats matching no rule don't change, and floor never changes.
        when :sightline
          cell.replace cell.tr([EMPTY,   FULL].join,
                               [[FILLING,FULL].join,     # 0
                                [EMPTY,  FULL].join,     # 1
                                [EMPTY,  FULL].join,     # 2
                                [EMPTY,  FULL].join,     # 3
                                [EMPTY,  FULL].join,     # 4
                                [EMPTY,  EMPTYING].join, # 5
                                [EMPTY,  EMPTYING].join, # 6
                                [EMPTY,  EMPTYING].join, # 7
                                [EMPTY,  EMPTYING].join, # 8
                               ][sightline(row_index, cell_index)])
        end
      end
    end
    @grid = @grid.map{|row| row.map{|cell| cell.tr([FILLING, EMPTYING].join,
                                                   [FULL,    EMPTY   ].join)} }
  end

  def to_s
    @grid.map{|_|_.join}.join("\n")
  end

  def size
    [@grid.size, @grid.map{|_|_.length}.max]
  end

  def empty_seats
    @grid.map{|_|_.join.count(EMPTY)}.reduce(:+)
  end
  def occupied_seats
    @grid.map{|_|_.join.count(FULL)}.reduce(:+)
  end
end
grid = Grid.new(input)

top = `tput ho`
steps = 114                     # or fewer actually
last_seats = grid.occupied_seats
steps.times {|i| grid.cycle;
  puts top, i;
  print grid.to_s;
  print "  "; puts grid.occupied_seats
  if debugging
    gets
  else
    sleep 0.05
  end
  break if last_seats == grid.occupied_seats
  last_seats = grid.occupied_seats
}

part1 = grid.occupied_seats

# --- Part Two ---

# As soon as people start to arrive, you realize your mistake. People don't just care about
# adjacent seats - they care about the first seat they can see in each of those eight directions!

# Now, instead of considering just the eight immediately adjacent seats, consider the first seat
# in each of those eight directions. For example, the empty seat below would see eight occupied
# seats:

# .......#.
# ...#.....
# .#.......
# .........
# ..#L....#
# ....#....
# .........
# #........
# ...#.....

# The leftmost empty seat below would only see one empty seat, but cannot see any of the occupied
# ones:

# .............
# .L.L.#.#.#.#.
# .............

# The empty seat below would see no occupied seats:

# .##.##.
# #.#.#.#
# ##...##
# ...L...
# ##...##
# #.#.#.#
# .##.##.

# Also, people seem to be more tolerant than you expected: it now takes five or more visible
# occupied seats for an occupied seat to become empty (rather than four or more from the previous
# rules). The other rules still apply: empty seats that see no occupied seats become occupied,
# seats matching no rule don't change, and floor never changes.

# Given the same starting layout as above, these new rules cause the seating area to shift around as follows:

# L.LL.LL.LL
# LLLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....

# LLLLLLLLLL
# L.LLLLLL.L
# L.LLLLL.LL
# #.##.##.##
# #######.##
# #.#.#..#..
# ####.##.##

# #.##.##.##
# #.#####.##
# ..#.#.....
# ##########
# #.######.#
# #.#####.##
# #.LL.LL.L#

# #LLLLLL.LL
# L.L.L..L..
# LLLL.LL.LL
# L.LL.LL.LL
# L.LLLLL.LL
# ..L.L.....
# LLLLLLLLL#

# #.LLLLLL.L
# #.LLLLL.L#
# #.L#.##.L#
# #L#####.LL
# L.#.#..#..
# ##L#.##.##
# #.##.#L.##

# #.#####.#L
# ..#.#.....
# LLL####LL#
# #.L#####.L
# #.L####.L#
# #.L#.L#.L#
# #LLLLLL.LL

# L.L.L..#..
# ##LL.LL.L#
# L.LL.LL.L#
# #.LLLLL.LL
# ..L.L.....
# LLLLLLLLL#
# #.LLLLL#.L

# #.L#LL#.L#
# #.L#.L#.L#
# #LLLLLL.LL
# L.L.L..#..
# ##L#.#L.L#
# L.L#.#L.L#
# #.L####.LL

# ..#.#.....
# LLL###LLL#
# #.LLLLL#.L
# #.L#LL#.L#
# #.L#.L#.L#
# #LLLLLL.LL
# L.L.L..#..

# ##L#.#L.L#
# L.L#.LL.L#
# #.LLLL#.LL
# ..#.L.....
# LLL###LLL#
# #.LLLLL#.L
# #.L#LL#.L#

# Again, at this point, people stop shifting around and the seating area reaches equilibrium. Once
# this occurs, you count 26 occupied seats.

# Given the new visibility method and the rule change for occupied seats becoming empty, once
# equilibrium is reached, how many seats end up occupied?

if debugging
  # For example, the empty seat below would see eight occupied seats:
  grid = Grid.new <<~END
         .......#.
         ...#.....
         .#.......
         .........
         ..#L....#
         ....#....
         .........
         #........
         ...#.....
         END
  puts grid, 8, grid.send(:sightline, 4, 3)

  # The leftmost empty seat below would only see one empty seat, but cannot see any of the occupied
  # ones:

  grid = Grid.new <<~END
         .............
         .L.L.#.#.#.#.
         .............
         END
  puts grid, 0, grid.send(:sightline, 1, 1)

  # The empty seat below would see no occupied seats:

  grid = Grid.new <<~END
         .##.##.
         #.#.#.#
         ##...##
         ...L...
         ##...##
         #.#.#.#
         .##.##.
         END
  puts grid, 0, grid.send(:sightline, 3, 3)

  # exit
end

grid = Grid.new(input)          # starting fresh
steps = 83                      # or fewer actually
last_seats = grid.occupied_seats
steps.times {|i| grid.cycle(rule: :sightline);
  puts top, i;
  print grid.to_s;
  print "  "; puts grid.occupied_seats
  if debugging
    gets
  else
    sleep 0.05
  end
  break if last_seats == grid.occupied_seats
  last_seats = grid.occupied_seats
}

puts
puts "Part 1:", part1
puts "Part 2:", grid.occupied_seats
