module ProcessCommand
  # Setting up variables and constants
  WHITELISTED_COMMANDS = ['DEFINE', 'CREATE', 'ADVANCE', 'DECIDE', 'STATS']
  @@defined_stages = {}

  def self.validate_presence_of_defined_stages(line, line_index)
    given_command = line.split(' ').first

    if line_index.zero? && given_command != 'DEFINE' 
      puts 'Operation terminated early, please define hiring stages first'
      return false
    end

    true
  end

  def self.formulate_output_line(line)
    full_inputs = line.split(' ')
    given_command = full_inputs.first
    inputs = full_inputs.drop(1)

    if WHITELISTED_COMMANDS.include?(given_command)
      # Prevent exception when the input line does not have other arguments beside 
      # the command except when the command is not STATS
      return nil if inputs.empty? && given_command != 'STATS' 

      case given_command
      when 'DEFINE'
        newline = self.defining_stages(given_command, inputs)
      when 'CREATE'
        newline = ManageApplicant.register(inputs, @@first_stage)      
      when 'ADVANCE'
        newline = ManageApplicant.advance_stage(inputs, @@defined_stages, given_command) 
      when 'DECIDE'
        newline = ManageApplicant.make_decision(inputs, @@last_stage)
      when 'STATS'
        newline = ManageApplicant.gathering_stats(@@defined_stages)
      end

      newline
    end
  end

  private

  def self.defining_stages(given_command, inputs)
    inputs.each_with_index { |e,i| @@defined_stages[e] = i }
    stages_stringified = @@defined_stages.keys.join(' ')

    @@first_stage = inputs.first
    @@last_stage = inputs.last

    given_command + ' ' + stages_stringified
  end
end