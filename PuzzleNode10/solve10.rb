#!/usr/bin/env ruby
#@author Scott M Parrish<anithri@gmail.com>

load 'circuit.rb'
#Define a regexp for an empty line to split the input file with.
EMPTY_LINE = /^[^-|01ANXO@#]*$/

#print usage unless called with only 1 argument
unless ARGV.length == 1
  puts "usage: solve.rb FILE"
  exit 1
end

#Make sure the file exists before we try to read it.
unless File.exist?(ARGV[0])
  puts "#{ARGV[0]} does not seem to exist.  Please check the file and try again."
end
#get the input file
contents = File.readlines(ARGV[0])

#take the array of contents, carve into slices based on the EMPTY LINE regexp
#iterate through the results
contents.slice_before(EMPTY_LINE).each do |a|
  #Create a new Circuit object, using this particular circuit
  #output the result as on/off
  puts Circuit.new(a).find_value ? "on" : "off"
end

