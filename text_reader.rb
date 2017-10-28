filename = ARGV.first

# txt = open(filename)

# puts "Here's your file #{filename}:"
# print txt.read

# puts "Here's your file #{filename}:"

HIRED_DECISION_BIN = 1
defined_stages = {}
last_stage = nil

applicants = {}

hired_count = 0
rejected_count = 0

WHITELISTED_COMMANDS = ['DEFINE', 'CREATE', 'ADVANCE', 'DECIDE', 'STATS']

output = File.new("output.txt", "w")

puts "Here are the outputs: "

File.foreach(filename) do |line|
  strings = line.split(' ')
  given_command = strings.first
  
  # puts line

  if WHITELISTED_COMMANDS.include?(given_command)
    
    rest_of_lines = strings.drop(1)

    if given_command == 'DEFINE'
      rest_of_lines.each_with_index { |e,i| defined_stages[e] = i }
      last_stage = rest_of_lines.last

      output.puts(given_command + ' ' + defined_stages.keys.join(' '))
    elsif given_command == 'CREATE'
      email = rest_of_lines.first

      if applicants[email].nil?
        applicants[email] = defined_stages.keys.first
        output.puts(line)
      else
        output.puts('Duplicate applicant')
      end

    elsif given_command == 'ADVANCE'
      email = rest_of_lines.first
      input_stage = rest_of_lines.size > 1 ? nil : rest_of_lines.last

      current_stage = applicants[email]
      is_last_stage = current_stage == last_stage

      # Check first if the applicant is already in the last stage
      if is_last_stage
        output.puts("Already in #{current_stage}")
      else
        # Check if the STAGE_NAME argument is nil or not,
        # if nil, then just advance 1 stage ahead.
        if input_stage.nil?
          current_stage_index = defined_stages[current_stage]
          next_stage_index = current_stage_index + 1
          next_stage = defined_stages.key(next_stage_index)

          output.puts(given_command + ' ' + next_stage)
        else
          is_same_stage = current_stage == input_stage

          if is_same_stage
            output.puts("Already in #{current_stage}")
          else
            output.puts(given_command + ' ' + input_stage)
          end
        end        
      end
    
    elsif given_command == 'DECIDE'
      email = rest_of_lines.first
      decision_input = rest_of_lines.size > 2 ? nil : rest_of_lines.last
      return output.puts("Failed to decide for #{email}") if decision_input.nil?

      # HIRING decision rules
      is_to_be_hired = decision_input == HIRED_DECISION_BIN
      is_hireable = applicants[email] == last_stage

      if is_to_be_hired && is_hireable
        hired_count += 1
        return output.puts("Hired #{email}")
      end

      rejected_count += 1
      output.puts("Rejected #{email}")

    elsif given_command == 'STATS'
      statement = ''

      defined_stages.keys.each do |stage|
        total = applicants.select { |_email, current_stage| 
          current_stage == stage  
        }.size

        statement.concat("#{stage} #{total} ")
      end

      statement.concat("Hired #{hired_count} ")
      statement.concat("Rejected #{rejected_count}")

      output.puts(statement)
    end  
  end
end


output.close