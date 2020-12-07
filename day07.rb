# --- Day 7: Handy Haversacks ---

# You land at the regional airport in time for your next flight. In fact, it looks like you'll
# even have time to grab some food: all flights are currently delayed due to issues in luggage
# processing.
#
# Due to recent aviation regulations, many rules (your puzzle input) are being enforced about bags
# and their contents; bags must be color-coded and must contain specific quantities of other
# color-coded bags. Apparently, nobody responsible for these regulations considered how long they
# would take to enforce!
#
# For example, consider the following rules:
#
# light red bags contain 1 bright white bag, 2 muted yellow bags.
# dark orange bags contain 3 bright white bags, 4 muted yellow bags.
# bright white bags contain 1 shiny gold bag.
# muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
# shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
# dark olive bags contain 3 faded blue bags, 4 dotted black bags.
# vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
# faded blue bags contain no other bags.
# dotted black bags contain no other bags.
#
# These rules specify the required contents for 9 bag types. In this example, every faded blue bag
# is empty, every vibrant plum bag contains 11 bags (5 faded blue and 6 dotted black), and so on.
#
# You have a shiny gold bag. If you wanted to carry it in at least one other bag, how many
# different bag colors would be valid for the outermost bag? (In other words: how many colors can,
# eventually, contain at least one shiny gold bag?)
#
# In the above rules, the following options would be available to you:
#
#
# A bright white bag, which can hold your shiny gold bag directly.

# A muted yellow bag, which can hold your shiny gold bag directly, plus some other bags.

# A dark orange bag, which can hold bright white and muted yellow bags, either of which could then
# hold your shiny gold bag.

# A light red bag, which can hold bright white and muted yellow bags, either of which could then
# hold your shiny gold bag.

# So, in this example, the number of bag colors that can eventually contain at least one shiny gold bag is 4.
#
# How many bag colors can eventually contain at least one shiny gold bag? (The list of rules is
# quite long; make sure you get all of it.)
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
    light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags.
  END
else
  puts "solving day #{day} from input"
end

class Rule
  attr_accessor :color, :contains

  PATTERN=/\A(?<color>.*?) bags contain (?<list>.*)\.\z/
  CONTENTS=/\A(\d+) ([\w ]+) bags?\z/

  def initialize(rule)
    if (md = PATTERN.match(rule))
      @color = md['color']
      @contains = {}
      unless md['list'] == 'no other bags'
        md['list'].split(/, /).map {|bag| CONTENTS.match(bag).captures }.each do |qty,color|
          @contains[color] = qty.to_i
        end
      end
    else
      puts "no match for #{rule.inspect}"
    end
  end

  def to_s
    str = "#{self.color} bags contain "
    if self.contains.empty?
      str << "no other bags"
    else
      str << self.contains.map {|color,qty| "#{qty} #{color} bag#{'s' unless qty == 1}" }.join(', ')
    end
    str << '.'
  end

  def bags_inside(rules)
    self.contains.map {|color,qty| qty * (1 + rules[color].bags_inside(rules)) }.sum
  end

end

rules = {}                      # 'color' => {'color' => numer}

input.each_line(chomp: true) do |line|
  puts line if debugging
  rule = Rule.new(line)
  puts rule.to_s if debugging || line != rule.to_s
  rules[rule.color] = rule
end

puts "#{rules.count} rules found" if debugging

puts 'Part 1:'

mine = 'shiny gold'

full = {}

require 'set'

rules.each_key do |color|
  to_expand = [color]
  expanded = Set.new
  # puts "#{color}: #{to_expand.inspect} => #{expanded.inspect}" if debugging
  while (expanding = to_expand.shift)
    unless expanded.include?(expanding)
      expanded << expanding
      to_expand.concat rules[expanding].contains.keys
      # puts "#{color}: #{to_expand.inspect} => #{expanded.inspect}" if debugging
    end
  end
  full[color] = expanded
end
puts full.inspect if debugging

puts full.each_value.count {|colors| colors.include?(mine) } - (full.key?(mine) ? 1 : 0)

# --- Part Two ---

# It's getting pretty expensive to fly these days - not because of ticket prices, but because of
# the ridiculous number of bags you need to buy!

# Consider again your shiny gold bag and the rules from the above example:

# faded blue bags contain 0 other bags.
# dotted black bags contain 0 other bags.
# vibrant plum bags contain 11 other bags: 5 faded blue bags and 6 dotted black bags.
# dark olive bags contain 7 other bags: 3 faded blue bags and 4 dotted black bags.

# So, a single shiny gold bag must contain 1 dark olive bag (and the 7 bags within it) plus 2
# vibrant plum bags (and the 11 bags within each of those): 1 + 1*7 + 2 + 2*11 = 32 bags!

# Of course, the actual rules have a small chance of going several levels deeper than this
# example; be sure to count all of the bags, even if the nesting becomes topologically
# impractical!

# Here's another example:

# shiny gold bags contain 2 dark red bags.
# dark red bags contain 2 dark orange bags.
# dark orange bags contain 2 dark yellow bags.
# dark yellow bags contain 2 dark green bags.
# dark green bags contain 2 dark blue bags.
# dark blue bags contain 2 dark violet bags.
# dark violet bags contain no other bags.

# In this example, a single shiny gold bag must contain 126 other bags.

# How many individual bags are required inside your single shiny gold bag?

puts 'Part 2:', rules[mine].bags_inside(rules)
