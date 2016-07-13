require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase

  test 'active_submission should be the last submission' do
    student = Student.create
    submissions = 3.times.map{ Submission.create(participant: student) }
    assert_equal submissions.last, student.active_submission
  end

end
