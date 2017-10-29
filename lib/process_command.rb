module ProcessCommand
  # Setting up variables and constants
  WHITELISTED_COMMANDS = ['DEFINE', 'CREATE', 'ADVANCE', 'DECIDE', 'STATS']
  @@defined_stages = {}
  @@line_index = 0

  def self.execute(full_inputs, output)
    given_command = full_inputs.first

    if WHITELISTED_COMMANDS.include?(given_command)
      
      inputs = full_inputs.drop(1)


      if given_command == 'DEFINE'
        
        inputs.each_with_index { |e,i| @@defined_stages[e] = i }
        newline = given_command + ' ' + @@defined_stages.keys.join(' ')
        
      elsif given_command == 'CREATE'

        newline = ManageApplicant.register(inputs.first, @@defined_stages.keys.first)      

      elsif given_command == 'ADVANCE'

        newline = ManageApplicant.advance_stage(
          inputs, @@defined_stages, given_command
        )      
      
      elsif given_command == 'DECIDE'

        newline = ManageApplicant.make_decision(inputs, @@defined_stages.keys.last)      

      elsif given_command == 'STATS'

        newline = ManageApplicant.gathering_stats(@@defined_stages)      

      end

      output.puts(newline)
    end

    @@line_index += 1
  end
end