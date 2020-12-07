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
  END
else
  puts "solving day #{day} from input"
end

input.each_line(chomp: true) do |line|
  puts line if debugging
end
