module ProcessCommand
  # Setting up variables and constants
  WHITELISTED_COMMANDS = ['DEFINE', 'CREATE', 'ADVANCE', 'DECIDE', 'STATS']
  @@defined_stages = {}

  def self.execute(given_command, inputs, output)
    if WHITELISTED_COMMANDS.include?(given_command)

      case given_command
      when 'DEFINE'        
        newline = self.defining_stages(given_command, inputs)
      when 'CREATE'
        newline = ManageApplicant.register(inputs.first, @@defined_stages.keys.first)      
      when 'ADVANCE'
        newline = ManageApplicant.advance_stage(inputs, @@defined_stages, given_command) 
      when 'DECIDE'
        newline = ManageApplicant.make_decision(inputs, @@defined_stages.keys.last)
      when 'STATS'
        newline = ManageApplicant.gathering_stats(@@defined_stages)
      end

      output.puts(newline)
    end
  end

  private

  def self.defining_stages(given_command, inputs)
    inputs.each_with_index { |e,i| @@defined_stages[e] = i }
    stages_stringified = @@defined_stages.keys.join(' ')

    given_command + ' ' + stages_stringified
  end
end