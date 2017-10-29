# type: ruby test/process_command_test.rb to run it
require 'minitest/autorun'
require_relative '../lib/manage_applicant.rb'
require_relative '../lib/process_command.rb'

class ProcessCommandTest < Minitest::Test
  def setup
    @define_command = 'DEFINE ManualReview BackgroundCheck'
    @create_command = 'CREATE howon@fountain.com'
    @advance_command = 'ADVANCE howon@fountain.com'
    @decide_command = 'DECIDE howon@fountain.com 1'
  end

  def test_failing_validation_for_defined_stages_presence
    result = ProcessCommand.validate_presence_of_defined_stages(@create_command, 0)

    assert_equal false, result
  end

  def test_passing_validation_for_defined_stages_presence
    result = ProcessCommand.validate_presence_of_defined_stages(@define_command, 0)

    assert_equal true, result
  end

  def test_executing_series_of_commands
    result_define = ProcessCommand.formulate_output_line(@define_command)
    result_register = ProcessCommand.formulate_output_line(@create_command)
    result_advance = ProcessCommand.formulate_output_line(@advance_command)
    result_decide = ProcessCommand.formulate_output_line(@decide_command)
    result_stats = ProcessCommand.formulate_output_line('STATS')

    assert_equal 'DEFINE ManualReview BackgroundCheck', result_define
    assert_equal @create_command, result_register
    assert_equal @advance_command, result_advance
    assert_equal 'Hired howon@fountain.com', result_decide
    assert_equal 'ManualReview 0 BackgroundCheck 0 Hired 1 Rejected 0', result_stats
  end

  # Sorry, for repeating the test I do not want to screw up ^_^
  def test_executing_series_of_commands_again #for sanity
    # The actual results
    results = []
    [
      'DEFINE ManualReview BackgroundCheck',
      'CREATE dan@fountain.com',
      'CREATE paul@fountain.com',
      'CREATE paul@fountain.com',
      'ADVANCE paul@fountain.com',
      'ADVANCE paul@fountain.com BackgroundCheck',
      'DECIDE paul@fountain.com 1',
      'DECIDE dan@fountain.com 1',
      "ADVANCE dan@fountain.com",
      'DECIDE dan@fountain.com 1'

    ].each do |line|
      results << ProcessCommand.formulate_output_line(line)
    end

    # The expected results
    [
      'DEFINE ManualReview BackgroundCheck',
      'CREATE dan@fountain.com',
      'CREATE paul@fountain.com',
      'Duplicate applicant',
      'ADVANCE paul@fountain.com',
      'Already in BackgroundCheck',
      'Hired paul@fountain.com',
      'Failed to decide for dan@fountain.com',
      'ADVANCE dan@fountain.com',
      'Hired dan@fountain.com' 
    ].each_with_index do |output_line, index|
      assert_equal output_line, results[index]
    end
  end  
end