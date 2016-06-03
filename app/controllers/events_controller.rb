class EventsController < ApplicationController
  before_action :set_event, only: [:show, :show_desired_owned_games]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @attending_players = @event.players.order(:meetup_username)
    @owned_game_ids = Ownership.where(player_id: @event.players).select(:game_id).distinct.map(&:game_id)

    @desired_game_counts = PlayWish.where(player_id: @event.players).group(:game_id).count.sort_by{|i,c| c}.reverse[0..10]
    @owned_and_desired_game_counts = PlayWish.where(player_id: @event.players, game_id: @owned_game_ids).group(:game_id).count.sort_by{|i,c| c}.reverse[0..10]
    @owned_and_desired_games_by_id = Hash[ (Game.where(id: @owned_and_desired_game_counts.map {|i| i[0]} ).map{|g| [g.id, g]})]
    
    if has_chosen_player?
      @chosen_player_owned_desired_games = @chosen_player.which_of_my_games_are_desired_by(@event.players)
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :provided_url, :meetup_id, :status, :event_time)
    end
end
