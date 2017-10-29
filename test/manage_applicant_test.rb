# type: ruby test/manage_applicant_test.rb to run it
require 'minitest/autorun'
require_relative '../lib/manage_applicant.rb' 

class ManageApplicantTest < Minitest::Test
  def setup
    @defined_stages = { 'ManualReview' => 0, 'BackgroundCheck' => 1, 'DocumentSigning' => 2 }
    @first_stage = @defined_stages.keys.first
  end

  def test_registering_new_applicant
    email = 'galih@lorem.com' # wink wink, shameless plug

    assert_equal "CREATE #{email}", ManageApplicant.register([email], @first_stage)
    # Now that the applicant has been registered, the next register attempt 
    # should yield different result
    assert_equal 'Duplicate applicant', ManageApplicant.register([email], 'First Stage')
  end

  def test_advancing_stage_with_no_stage
    given_command = 'ADVANCE'
    inputs = ['howon@fountain.com']

    ManageApplicant.register(inputs, @first_stage)
    result = ManageApplicant.advance_stage(inputs, @defined_stages, given_command)

    assert_equal given_command + ' ' + inputs.first, result
  end

  def test_advancing_stage_to_certain_stage
    given_command = 'ADVANCE'
    advance_to = @defined_stages.keys.last
    inputs = ['paul@fountain.com', advance_to]

    ManageApplicant.register(inputs, @first_stage)
    advance_result = ManageApplicant.advance_stage(inputs, @defined_stages, given_command)

    assert_equal given_command + ' ' + inputs.first, advance_result

    second_advance_result = ManageApplicant.advance_stage(inputs, @defined_stages, given_command)
    assert_equal 'Already in ' + advance_to, second_advance_result
  end

  def test_deciding_hired_application
    email = 'galih0muhammad@gmail.com'
    given_command = 'DECIDE'
    last_stage = @defined_stages.keys.last
    advance_inputs = [email, last_stage]
    decide_inputs = [email, 1]

    ManageApplicant.register([email], @first_stage)
    ManageApplicant.advance_stage(advance_inputs, @defined_stages, given_command)
    result = ManageApplicant.make_decision(decide_inputs, last_stage)

    assert_equal "Hired #{email}", result

    # In meantime, check that this application should not be able to be advanced
    second_result = ManageApplicant.advance_stage([email], @defined_stages, 'ADVANCE')
    assert_equal "The application of #{email} has been decided already", second_result
  end

  def test_deciding_rejected_application
    email = 'not_galih@gmail.com'
    given_command = 'DECIDE'
    last_stage = @defined_stages.keys.last
    advance_inputs = [email, last_stage]
    decide_inputs = [email, 0]

    ManageApplicant.register([email], @first_stage)
    ManageApplicant.advance_stage(advance_inputs, @defined_stages, given_command)
    result = ManageApplicant.make_decision(decide_inputs, last_stage)

    assert_equal "Rejected #{email}", result
  end

  def test_deciding_failed_to_decide_application
    email = 'somebody@gmail.com'
    given_command = 'DECIDE'
    last_stage = @defined_stages.keys.last
    advance_inputs = [email, last_stage]
    decide_inputs = [email]

    ManageApplicant.register([email], @first_stage)
    result = ManageApplicant.make_decision(decide_inputs, last_stage)

    assert_equal "Failed to decide for #{email}", result
  end

  def test_gathering_stats
    result = ManageApplicant.gathering_stats(@defined_stages)

    assert_equal false, result.empty?
  end
end