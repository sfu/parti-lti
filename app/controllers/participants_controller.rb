class ParticipantsController < ApplicationController

  before_action :authenticate_user!

  def index
    @room = Room.find_by(id: params[:room_id])
    return redirect_to :root, alert: 'Room not found' unless @room
  end

  def passback_grade
    @room = Room.find_by(id: params[:room_id])
    return render_json(false, 'Room not found') unless @room
    return render_json(false, 'Room not fully set up to passback grades') unless @room.can_passback_grades?
    @current_participant = @room.participants.find_by(user: current_user)
    return render_json(false, 'Only teachers can export') unless @current_participant && @current_participant.teacher?
    @participant = @room.students.find_by(id: params[:id])
    return render_json(false, 'Participant not found') unless @participant
    return render_json(false, 'No grade passback ID') unless @participant.grade_passback_id.present?
    @submission = @participant.active_submission
    return render_json(false, 'Participant has not submitted') unless @submission
    return render_json(false, 'Submission has not been rated') unless @submission.rating.present?

    key = @room.lti_tool_consumer.oauth_consumer_key
    secret = @room.lti_tool_consumer.oauth_shared_secret
    params = {
        'lis_outcome_service_url' => @room.grade_passback_url,
        'lis_result_sourcedid' => @participant.grade_passback_id
    }
    tool_provider = IMS::LTI::ToolProvider.new(key, secret, params)

    grade = @submission.normalized_rating
    begin
      response = tool_provider.post_replace_result!(grade)
      render_json(response.success?)
    rescue IMS::LTI::InvalidLTIConfigError
      render_json(false, 'LTI configuration error')
    end
  end

  private

  def render_json(success, error = nil)
    result = {success: success}
    result[:error] = error if error
    render json: result
  end

end
