module ManageApplicant
  # Setting up variables and constants
  HIRED_DECISION_BIN = 1
  @@decision_counter = { hired: 0, rejected: 0 }
  @@applicants = {}

  def self.execute_command
  end

  def self.register(email, first_stage)
    if @@applicants[email].nil?
      @@applicants[email] = first_stage
      
      "CREATE #{email}"
    else
      'Duplicate applicant'
    end
  end

  def self.advance_stage(inputs, defined_stages, given_command)
    email = inputs.first
    input_stage = inputs.size > 1 ? nil : inputs.last

    current_stage = @@applicants[email]
    is_last_stage = current_stage == defined_stages.keys.last

    # Check first if the applicant is already in the last stage
    if is_last_stage
      "Already in #{current_stage}"
    else
      # Check if the STAGE_NAME argument is nil or not,
      # if nil, then just advance 1 stage ahead.
      if input_stage.nil?
        current_stage_index = defined_stages[current_stage]

        next_stage_index = current_stage_index + 1
        next_stage = defined_stages.key(next_stage_index)
        
        # Move the stage for the applicants
        @@applicants[email] = next_stage

        given_command + ' ' + next_stage
      else
        is_same_stage = current_stage == input_stage
        return "Already in #{current_stage}" if is_same_stage

        # Move the stage for the applicants
        @@applicants[email] = next_stage

        given_command + ' ' + input_stage
      end        
    end
  end

  def self.make_decision(inputs, last_stage)
    email = inputs.first
    decision_input = inputs.size > 2 ? nil : inputs.last
    return "Failed to decide for #{email}" if decision_input.nil?

    # Set current_stage for the applicant to nil to indicate that decision has been made
    @@applicants[email] = nil

    # HIRING decision rules
    is_to_be_hired = decision_input == HIRED_DECISION_BIN
    is_hireable = @@applicants[email] == last_stage

    if is_to_be_hired && is_hireable
      self.increment_counter(:hired)
      "Hired #{email}"
    end

    self.increment_counter(:rejected)
    "Rejected #{email}"
  end

  def self.gathering_stats(defined_stages)
    statement = ''

    defined_stages.keys.each do |stage|
      total = @@applicants.select { |_email, current_stage| 
        current_stage == stage  
      }.size

      statement.concat("#{stage} #{total} ")
    end

    statement.concat("Hired #{@@decision_counter[:hired]} ")
    statement.concat("Rejected #{@@decision_counter[:rejected]}")

    statement
  end

  private

  def self.increment_counter(counter_sym)
    @@decision_counter[counter_sym] += 1
  end
end