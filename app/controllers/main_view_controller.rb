class MainViewController < ApplicationController

  before_action :authenticate_user!

  def index
     @room = Room.find_by_id(params[:room_id])
     render text: "Room not found." if @room.nil?
  end
end
