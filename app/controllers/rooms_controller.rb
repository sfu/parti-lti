class RoomsController < ApplicationController

  before_action :authenticate_user!

  def index
    # Get user's rooms (filtered by context of the specified room, if any)
    filtering_room = current_user.rooms.find_by(id: params[:filtering_room_id])
    if filtering_room
      filter = {
          lti_tool_consumer: filtering_room.lti_tool_consumer,
          lti_context_type: filtering_room.lti_context_type,
          lti_context_id: filtering_room.lti_context_id
      }
      @filtered = true
    end
    @rooms = current_user.rooms.where(filter)
  end

  def show
    @room = Room.find_by(id: params[:id])
    return redirect_to :root, alert: 'Room not found' unless @room

    @participant = @room.participants.find_by(user: current_user)
    return redirect_to :root, alert: 'You are not on the Parti guest list' unless @participant

    redirect_to new_room_submission_path(@room) if @participant.student? && @room.open
    render :close_message if @participant.student? && !@room.open
  end

  def not_found; end

  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(room_params)
      flash[:notice] = 'The room was updated successfully'
    else
      flash[:alert] = 'An error occurred while editing the room'
    end
    redirect_to @room
  end

  def import_participants
    @room = Room.find_by(id: params[:id])
    return redirect_to :root, alert: 'Room not found' unless @room

    @participant = @room.participants.find_by(user: current_user)
    return redirect_to @room, alert: 'Permission denied' unless @participant.teacher? || @participant.moderator?

    return redirect_to @room, alert: @room.import_participants_error unless @room.can_import_participants?

    # Determine if the user already has an access token for this room's tool consumer (linked LMS)
    tool_consumer = @room.lti_tool_consumer
    token = current_user.token_for_tool_consumer(tool_consumer)
    client = tool_consumer.oauth2_client
    state = { id: tool_consumer.id, action: room_import_participants_url(@room) }.to_json
    @redirect = client.auth_code.authorize_url(redirect_uri: oauth2_callback_url, state: state)
    return render 'request_token' unless token

    access_token = token.oauth2_access_token
    # Refresh access token if it needs to (and can) be refreshed. If it can't be refreshed, it'll simply be rejected.
    if access_token.expired? && access_token.refresh_token.present?
      Rails.logger.info("OAuth2 access token for user #{current_user.id} has expired. Refreshing...")
      access_token = access_token.refresh!
      token.update_with_access_token(access_token)
    end

    enrollments = get_enrollments(access_token)
    if enrollments.is_a?(OAuth2::Error)
      error = enrollments
      if error.response.status == 401
        Rails.logger.info("OAuth2 access token for user #{current_user.id} was rejected. Destroying...")
        token.destroy
        @token_invalid = true
        return render 'request_token'
      end
    end
    # Results should be an Array if the query was successful
    return redirect_to @room, alert: 'Unable to fetch participants from source' unless enrollments.is_a?(Array)

    @added = []
    @unchanged = []
    importable, @skipped = enrollments.partition { |e| e['user'] && e['user']['sis_user_id'] }
    importable.each do |e|
      # Find the existing user, or create new user based on info given by the enrollment.
      pseudonym = Pseudonym.find_or_initialize_by(service: 'canvas', identifier: e['user']['sis_user_id'])
      if pseudonym.new_record?
        last_name, first_name = e['user']['sortable_name'].split(', ', 2)
        pseudonym.user = User.new(
            first_name: first_name,
            last_name: last_name,
            email: User.login_to_email(e['user']['login_id'])
        )
        pseudonym.save
      end

      if pseudonym.user.participants.find_by(room_id: @room)
        # Do nothing if the user is already a participant
        @unchanged << pseudonym.user
      else
        # Add the user as a participant based on the enrollment type
        if e['role'] == 'StudentEnrollment'
          @room.participants << Student.new(user: pseudonym.user)
        elsif e['role'] == 'TaEnrollment'
          @room.participants << Moderator.new(user: pseudonym.user)
        elsif e['role'] == 'TeacherEnrollment'
          @room.participants << Teacher.new(user: pseudonym.user)
        else
          Rails.logger.warn("Enrollment for #{e['user']['name']} cannot be added due to unknown role: #{e['role']}")
          @skipped << e
          next
        end
        @added << pseudonym.user
      end
    end
  end

  private

  def get_enrollments(access_token)
    enrollments = []
    next_link = "/api/v1/courses/#{@room.lti_context_id}/enrollments"

    loop do
      begin
        response = access_token.get(next_link)
      rescue OAuth2::Error => error
        return error
      end
      parsed_response = response.parsed

      # We are assuming that when the response is an array, the results are valid and error-free.
      return parsed_response unless parsed_response.is_a?(Array)
      enrollments += parsed_response

      # When the "next" link is absent, we know we have arrived at the last page.
      links = response.headers['link']
      next_link = links.match(/<(https?:\/\/[^>]*)>; rel="next"/).to_a[1]
      break unless next_link
    end

    enrollments
  end
  
  def room_params
    params.require(:room).permit(:name, :open)
  end

end
