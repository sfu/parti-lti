require 'zip'

class SubmissionsController < ApplicationController

  before_action :authenticate_user!
  before_action :redirect_if_room_close, only: [:new, :create]

  def index
    @room = Room.find_by_id(params[:room_id])
    render text: "Room not found." if @room.nil?
  end

  def patch
    # todo: check params
    # if submission ids are unique globally do we really need to retrieve
    # the room object? maybe we still need to check validity?
    submission = Submission.find(params[:id])
    submission.update(params[:submission].permit(:rating, :show, :starred, :flagged))
    submission.save
    render :json => params
  end

  def show
    @submission = Submission.find(params[:id])
    @room = Room.find(params[:room_id])
  end

  def new
    @submission = @participant.submissions.new
  end

  def create
    @submission = @participant.submissions.new(submission_params)
    if @submission.save
      flash[:notice] = "Successfully uploaded image."
      redirect_to new_room_submission_path(@room)
    else
      flash[:warn] = "Uploaded image not save. Please try again"
      render :action => 'new'
    end
  end

  def update
    raise 'Unsupported method' unless request.patch?
    patch
  end

  def who_submitted
    @room = Room.find(params[:room_id])
    user_list = @room.submissions.collect do |s|
      if !s.participant.user.last_name.empty?
        if !s.participant.user.first_name.empty?
          s.participant.user.last_name + ", " + s.participant.user.first_name
        else
          s.participant.user.last_name
        end
      else
        s.participant.user.first_name
      end
    end

    # Remove duplicate users if users uploaded more than once.
    user_list = user_list.uniq

    @sorted_groups = user_list.group_by { |u| u[0].upcase }
    @sg_keys = @sorted_groups.keys.sort
  end

  def export
    @room = Room.find(params[:room_id])
    participants = @room.participants.all
    redirect_to @room unless participants
    any_submission = false
    t = Tempfile.new("parti")
    cleaner = Paperclip::FilenameCleaner.new(/[^a-z0-9\.]/i)
    foldername = cleaner.call("#{@room.name}-submissions")

    Zip::File.open(t.path, Zip::File::CREATE) do |z|
      participants.each do |partic|
        last_submission = partic.active_submission
        next unless last_submission
        any_submission = true
        title = cleaner.call(partic.user.full_name + "_" + last_submission.image_file_name)
        z.add("#{foldername}/#{title}", last_submission.image.path)
      end
    end

    redirect_to @room, alert: "Cannot export submissions, since there's no submission." unless any_submission
    foldername = foldername +".zip"
    send_file t.path, :type => 'application/zip',
              :disposition => 'attachment',
              :filename => foldername if any_submission

    t.close
  end

  # returns a json of the newest submissions whose id is greater than
  # the specified id
  def newest_submissions
    @room = Room.find(params[:room_id])
    @beyond_id = params[:beyond_id]
    result = []
    @room.submissions.where("submissions.id > #{@beyond_id}").each do |s|
      sub = {
        id:  s.id,
        url: s.image.url(:medium),
        thumb: s.image.url(:thumb),
        show: s.show,
        star: s.starred,
        flag: s.flagged,
        rating: s.rating,
        participant_id: s.participant_id
      }
      result << sub
    end
    render :json => result
  end

  private

  def submission_params
    params.require(:submission).permit(:image)
  end

  def redirect_if_room_close
    @room = Room.find(params[:room_id])
    @participant = @room.participants.find_by(user: current_user)
    redirect_to @room unless @participant
    @last_submission = @participant.active_submission

    if @last_submission
      redirect_to room_submission_path(room_id: @room, id: @last_submission) unless @room.open
    else
      redirect_to @room, alert: 'You can not upload image since the room is closed.' unless @room.open
    end
  end

end
