require_relative 'lib/process_command'
require_relative 'lib/manage_applicant'

filename = ARGV.first.nil? ? 'input.txt' : ARGV.first
puts "Operation is starting, your file input is #{filename}"

output_name = 'output.txt'
output = File.new(output_name, "w")

File.foreach(filename) do |line|
  full_inputs = line.split(' ')
  
  ProcessCommand.execute(full_inputs, output)
end

output.close
puts "Operation went without a problem, please check #{output_name}"