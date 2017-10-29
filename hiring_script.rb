# To run the script, either type:
# ruby hiring_script.rb [any_other_input.txt]
# or just type: ruby hiring_script.rb
# as it will default to input.txt

require_relative 'lib/process_command'
require_relative 'lib/manage_applicant'

filename = ARGV.first.nil? ? 'input.txt' : ARGV.first
puts "Operation starts, your file input is #{filename}"

output_name = 'output.txt'
output = File.new(output_name, "w")

line_index = 0

File.foreach(filename) do |line|
  next if line.nil? || line.empty?
  # If the first command in input is not a DEFINE, then terminate the execution
  break unless ProcessCommand.validate_presence_of_defined_stages(line, line_index)

  newline = ProcessCommand.formulate_output_line(line)
  output.puts(newline)

  line_index += 1
end

output.close
puts "Operation is done"