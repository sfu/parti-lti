class Participant < ActiveRecord::Base

  belongs_to :user
  belongs_to :room
  has_many :submissions

  # We currently define the "active" submission as the last submission
  has_one :active_submission, -> { order 'created_at DESC' }, class_name: 'Submission'

  # Implement single-table inheritance (STI) using the "role" column
  self.inheritance_column = 'role'

  scope :teachers, -> { where(role: 'Teacher') }
  scope :moderators, -> { where(role: 'Moderator') }
  scope :students, -> { where(role: 'Student') }

  def teacher?
    self.is_a?(Teacher)
  end

  def moderator?
    self.is_a?(Moderator)
  end

  def student?
    self.is_a?(Student)
  end

  def can_passback_grade?
    grade_passback_id.present? && active_submission.present? && active_submission.has_rating?
  end

end
