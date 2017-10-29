require_relative 'lib/process_command'
require_relative 'lib/manage_applicant'

filename = ARGV.first.nil? ? 'input.txt' : ARGV.first
puts "Operation starts, your file input is #{filename}"

output_name = 'output.txt'
output = File.new(output_name, "w")

line_index = 0

File.foreach(filename) do |line|
  full_inputs = line.split(' ')
  given_command = full_inputs.first
  inputs = full_inputs.drop(1)

  if given_command != 'DEFINE' && line_index.zero?
    puts 'Operation terminated early, please define hiring stages first'
    break 
  end

  ProcessCommand.execute(given_command, inputs, output)

  line_index += 1
end

output.close
puts "Operation is done"