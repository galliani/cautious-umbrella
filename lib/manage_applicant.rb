module ManageApplicant
  # Setting up variables and constants
  HIRED_DECISION_BIN = 1
  @@decision_counter = { hired: 0, rejected: 0 }
  @@applicants = {}

  def self.register(inputs, first_stage)
    email = inputs.first
    return nil if email.nil?

    if @@applicants[email].nil?
      @@applicants[email] = first_stage
      
      "CREATE #{email}"
    else
      'Duplicate applicant'
    end
  end

  def self.advance_stage(inputs, defined_stages, given_command)
    email = inputs.first
    input_stage = inputs.size >= 2 ? inputs.last : nil 

    current_stage = @@applicants[email]
    return 'The given applicant is not registered' if current_stage.nil?

    if current_stage == 1 || current_stage == 0
      return "The application of #{email} has been decided already"
    end

    # Check first if the applicant is already in the last stage
    is_last_stage = current_stage == defined_stages.keys.last
    return "Already in #{current_stage}" if is_last_stage
      
    # Check if the STAGE_NAME argument is nil or not,
    # if nil, then just advance 1 stage ahead.
    if input_stage.nil?
      current_stage_index = defined_stages[current_stage]

      next_stage_index = current_stage_index + 1
      next_stage = defined_stages.key(next_stage_index)
      
      # Move the stage for the applicants
      @@applicants[email] = next_stage
    else
      is_same_stage = current_stage == input_stage
      return "Already in #{current_stage}" if is_same_stage

      # Move the stage for the applicants
      @@applicants[email] = input_stage
    end

    given_command + ' ' + email
  end

  def self.make_decision(inputs, last_stage)
    email = inputs.first
    current_stage = @@applicants[email]
    return 'The given applicant is not registered' if current_stage.nil?

    decision_input = inputs.size >= 2 ? inputs.last.to_i : nil
    return "Failed to decide for #{email}" if decision_input.nil?

    # HIRING decision rules
    is_to_be_hired = decision_input == HIRED_DECISION_BIN
    
    if is_to_be_hired
      is_hireable = @@applicants[email] == last_stage
      return self.finish_application(:hired, email) if is_hireable

      "Failed to decide for #{email}"
    else
      self.finish_application(:rejected, email)
    end
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

  def self.finish_application(counter_sym, email)
    @@decision_counter[counter_sym] += 1
    @@applicants[email] = counter_sym == :hired ? 1 : 0

    return "Hired #{email}" if counter_sym == :hired
    "Rejected #{email}"
  end
end