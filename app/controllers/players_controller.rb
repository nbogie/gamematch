class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update]

  # GET /players
  # GET /players.json
  def index
    ps = params.permit(:term, :offset)
    if (ps[:term])
      @players = Player.search(term: ps[:term], limit: 20, offset: ps[:offset] || 0)
    else
      @players = Player.where("players.bgg_username is NOT NULL").order(:meetup_username)
    end
  end

  # GET /players/unlinked_attending
  # GET /players/unlinked_attending.json
  def unlinked_attending
    @players = Player.attending_something_and_no_bgg_link
    render :index
  end
  
  def choose_player
    p = Player.find(params.require(:id))
    session[:chosen_player_id] = params.require(:id)
    redirect_to p, notice: "Focus on player: #{chosen_player.meetup_username}"
  end
  
  def choose_no_player
    session[:chosen_player_id] = nil
    redirect_to '/events', notice: "Defocused player"
  end
  
  # GET /players/1
  # GET /players/1.json
  def show
    #TODO: do this all in the db
    @owned_games = @player.owned_games #.includes(:ratings)
    @top_20_games = @player.rated_games.select('games.*, ratings.rating').order('ratings.rating desc, games.name').where('ratings.rating > 6').limit(20)
    playwish_counts_all = PlayWish.group(:game_id).count
    playwish_counts_all.default=0
    @playwish_counts = Hash[* @player.owned_games.map{ |g| [g.id, playwish_counts_all[g.id]] }.flatten ]

    top_ten = @playwish_counts.sort_by{|gid,n| n}.reverse[0..9]
    @most_desired_games = top_ten.map { |gid, n| 
      @owned_games.detect{|g| g.id == gid}
    }

    @playwish_counts = Hash[* top_ten.flatten]
    
    @uniquely_owned_games = Game.owned_uniquely_by(@player)
  end

  # GET /players/1/edit
  def edit
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    #TODO: protect this update method.
    respond_to do |format|
      if @player.update(player_params)
        @player.collection_processed_at = nil
        @player.save!
        format.html { redirect_to @player, notice: "Player was successfully updated.#{@player.link_string}" }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end


  def mark_stale
    id = params.require(:id)
    logger.debug("mark_stale with id #{id}")
    p = Player.find(id)
    p.collection_processed_at = nil
    p.save!
    redirect_to p, notice: "Player mark_stale successful."
  end

  def mark_searched
    id = params.require(:id)
    p = Player.find(id)
    p.searched_at = Time.now
    p.save!
    redirect_to p, notice: "Player mark_searched successful: #{p.link_string}"
  end

  def link_with_bgg_account
    logger.debug("in link_with_bgg_account #{params.require(:id)}")
    @player = Player.find(params.require(:id)[:id])
    if @player.update(params.require(:bgg_username))
      redirect_to @player, notice: "Player bgg_username successfully updated.  #{@player.link_string}"
    else
      redirect_to @player, notice: "Player bgg_username update failed.  Errors: #{@player.errors}"
    end
  end

  def player_names
    ps = params.permit(:term)
    if (ps[:term]) 
      @players = Player.search(ps)
    else
      @players = []
    end
    render json: @players.map(&:meetup_username)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:bgg_username)
    end
end
