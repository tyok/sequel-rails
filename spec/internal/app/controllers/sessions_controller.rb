class SessionsController < ApplicationController
  def create
    session[:status] = params[:status]
    head :status => 200
  end

  def destroy
    reset_session
    head :status => 200
  end
end
