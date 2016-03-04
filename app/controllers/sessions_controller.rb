class SessionsController < ApplicationController
  def new
    redirect_to '/auth/crest'
  end

  def create
    auth = request.env['omniauth.auth']
    user = User.where(uid: auth['uid'].to_s).first
    unless user.nil?
      user.delete
    end
    user = User.create_from_omniauth(auth)
    reset_session
    session[:user_id] = user.id
    redirect_to root_url, notice: 'Signed in!'
  end

  def destroy
    reset_session
    render nothing: true
    # redirect_to root_url, notice: 'Signed out!'
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end
end
