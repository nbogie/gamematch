class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #before every action of every controller
  before_action :chosen_player

  def chosen_player
    @chosen_player ||= session[:chosen_player_id] && Player.find(session[:chosen_player_id])
  end
  
  def has_chosen_player?
    ! @chosen_player.nil?
  end

end
