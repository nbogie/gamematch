class EventsController < ApplicationController
  before_action :set_event, only: [:show, :show_desired_owned_games, :workinprogress]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @attending_players = @event.players.order(:meetup_username)
    
    @desired_games       = Game.desired_games_for_players(@event.players)
    @desired_owned_games = Game.desired_games_for_players_owned_by_others(@event.players, @attending_players)

    if has_chosen_player?
      @chosen_player_owned_desired_games =  Game.desired_games_for_players_owned_by_others_eager_load_keen_players(@event.players, @chosen_player)
        #Game.desired_games_for_players_owned_by_others(@event.players.where('id is not ?', @chosen_player), @chosen_player)
      
    end

  end
  
  def workinprogress
    @desired_games =Game.desired_games_for_players_owned_by_others(@event.players, @chosen_player)

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
