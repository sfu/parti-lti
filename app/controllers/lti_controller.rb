require 'oauth/request_proxy/rack_request'

class LtiController < ApplicationController

  # External LTI Consumers cannot generate an authenticity token
  skip_before_filter :verify_authenticity_token, only: :launch

  def configuration; end

  def launch
    sign_out :user if user_signed_in?

    tool_consumer = LtiToolConsumer.find_by(oauth_consumer_key: params['oauth_consumer_key'])
    return render 'error_consumer_unknown' unless tool_consumer

    tool_provider = get_tool_provider(tool_consumer)
    return render 'error_oauth' unless tool_provider && tool_provider.valid_request?(request)

    required_fields = %w(tool_consumer_info_product_family_code lis_person_contact_email_primary lis_person_sourcedid)
    return render 'error_identity' unless required_fields.all?{ |k| params[k].present? }

    # Find the returning user, or create new user based on info given by the Tool Consumer.
    pseudonym = Pseudonym.find_or_initialize_by(
        service: params['tool_consumer_info_product_family_code'],
        identifier: params['lis_person_sourcedid']
    )
    if pseudonym.new_record?
      pseudonym.user = User.new(
          first_name: params['lis_person_name_given'],
          last_name: params['lis_person_name_family'],
          email: User.login_to_email(params['lis_person_contact_email_primary'])
      )
      pseudonym.save
    end

    # Log the user in automatically
    sign_in pseudonym.user

    context_type = params['custom_canvas_course_id'] ? 'course' : nil

    # If launching in list mode, show list of rooms that share the same context (e.g. course).
    if params['mode'] == 'list'
      rooms_in_context = params['custom_canvas_course_id'] ? current_user.rooms.where(
          lti_tool_consumer: tool_consumer,
          lti_context_type: context_type,
          lti_context_id: params['custom_canvas_course_id']
      ) : []
      # Use the first room with matching context as the filtering room (if any)
      filtering_room = rooms_in_context.any? ? rooms_in_context.first : nil
      return redirect_to root_path(filtering_room_id: filtering_room)
    end

    # Redirect to or create a room based on the resource that launched this
    if params['tool_consumer_info_product_family_code'] && params['resource_link_id']
      room = Room.find_by(lti_resource_link_id: params['resource_link_id'])
      if room
        return render 'error_consumer_changed' if room.lti_tool_consumer != tool_consumer
        if tool_provider.instructor? || tool_provider.student?
          if tool_provider.instructor?
            participant = Teacher.find_or_initialize_by(user: current_user, room: room)
          elsif tool_provider.student?
            participant = Student.find_or_initialize_by(user: current_user, room: room)
            if room.grade_passback_url && params['lis_result_sourcedid'].present?
              participant.grade_passback_id = params['lis_result_sourcedid']
            end
          end
          if participant.new_record? || participant.changed?
            participant.save
          end
        end
        return redirect_to room
      else
        if tool_provider.instructor?
          room = Room.new(
              name: params['resource_link_title'],
              open: true,
              lti_tool_consumer: tool_consumer,
              lti_resource_link_id: params['resource_link_id'],
              lti_context_type: context_type,
              lti_context_id: params['custom_canvas_course_id'],
              grade_passback_url: params['lis_outcome_service_url']
          )
          room.participants << Teacher.new(user: current_user)

          if room.save
            if room.can_import_participants?
              # Perform the initial import right away to add everyone into the room
              return redirect_to room_import_participants_path(room), notice: 'The room has been created successfully'
            else
              return redirect_to room
            end
          else
            error = room.errors.any? ? room.errors.full_messages.first : 'Unknown error'
            return redirect_to :root, alert: "The room cannot be created: #{error}"
          end
        elsif tool_provider.student?
          return redirect_to room_not_found_path
        else
          return redirect_to :root, alert: 'Cannot create room because you are not a teacher'
        end
      end
    end

    # Fall back to home page
    redirect_to :root, alert: 'Unexpected error occurred at launch'
  end

  private

  def get_tool_provider(tool_consumer)
    IMS::LTI::ToolProvider.new(tool_consumer.oauth_consumer_key, tool_consumer.oauth_shared_secret, params)
  end

  def get_url_root
    return nil unless params['launch_presentation_return_url']

    # Normally, we can simply extract the URL root (scheme/host/port) from launch_presentation_return_url.
    # However, sometimes it is missing the URL root portion, so we need to fallback to custom_canvas_api_domain.
    # NOTE: We are assuming the scheme is HTTPS when using the fallback.
    url_root = params['launch_presentation_return_url'][/^(https?:\/\/[^\/]*)\//, 1]
    if url_root.nil? && params['custom_canvas_api_domain']
      "https://#{params['custom_canvas_api_domain']}"
    else
      url_root
    end
  end

end
