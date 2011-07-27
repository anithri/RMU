#!/usr/bin/env ruby
#@author Scott M Parrish<anithri@gmail.com>
load 'cave.rb'

#print usage unless called with only 1 argument
unless ARGV.length == 1
  puts "usage: solve.rb FILE"
  exit 1
end

#Make sure the file exists before we try to read it.
unless File.exist?(ARGV[0])
  puts "#{ARGV[0]} does not seem to exist.  Please check the file and try again."
  exit 1
end

#get the input file
contents = File.readlines(ARGV[0])

#The first line tells us how many iterations to do and the second is blank, so I discard it.
iterations = contents.shift(2)[0].to_i - 1

#create a new cave object with the rest of the file
cave = Cave.new(contents)

#flow water through the cave based on the number of iterations.
cave.flow(iterations)

#output the depths array joined with spaces.
puts "#{cave.depths.join(" ")}"
