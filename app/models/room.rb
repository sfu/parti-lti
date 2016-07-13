class Room < ActiveRecord::Base

  has_many :participants
  has_many :users, :through => :participants
  has_many :submissions, :through => :participants
  delegate :teachers, :moderators, :students, to: :participants
  belongs_to :lti_tool_consumer

  validates :name, presence: true

  def import_participants_error
    return 'Only Canvas is supported' unless lti_tool_consumer && lti_tool_consumer.canvas?
    return 'Not linked to any Canvas instance' if lti_resource_link_id.blank?
    return 'Incomplete integration configuration' unless lti_tool_consumer.oauth2_configured?
    return 'Only Canvas courses are supported' unless lti_context_type == 'course'
    return 'Unknown external course' if lti_context_id.blank?
    nil
  end

  def can_import_participants?
    import_participants_error.nil?
  end

  def can_passback_grades?
    lti_tool_consumer && grade_passback_url.present?
  end

end
