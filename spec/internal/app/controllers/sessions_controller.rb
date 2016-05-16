class SessionsController < ApplicationController
  def create
    session[:status] = params[:status]
    head :ok
  end

  def destroy
    reset_session
    head :ok
  end
end
