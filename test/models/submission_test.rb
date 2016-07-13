require 'test_helper'

class SubmissionTest < ActiveSupport::TestCase

  test 'has_rating? should return nil when rating is nil' do
    submission = Submission.new(rating: nil)
    assert_not submission.has_rating?
  end

  test 'has_rating? should return nil when rating is -1' do
    submission = Submission.new(rating: -1)
    assert_not submission.has_rating?
  end

  test "normalized_rating should calculate correctly based on the room's maximum" do
    room = create(:room, max_rating: 5)
    submission = Submission.new(rating: 1, room: room)
    assert_equal submission.normalized_rating, 0.2

    room = create(:room, max_rating: 4)
    submission = Submission.new(rating: 2, room: room)
    assert_equal submission.normalized_rating, 0.5
  end

  test 'normalized_rating should return nil when submission is not rated' do
    submission = Submission.new(rating: -1, room: create(:room))
    assert_nil submission.normalized_rating
  end

end
