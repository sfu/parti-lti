class StatusController < ApplicationController
  def status
    render :text => "OK"
  end
end
