class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
    @players = Player.where("players.bgg_username is NOT NULL")
  end

  # GET /players/1
  # GET /players/1.json
  def show
    #TODO: do this all in the db
    playwish_counts_all = PlayWish.group(:game_id).count
    playwish_counts_all.default=0
    @playwish_counts = Hash[* @player.owned_games.map{ |g| [g.id, playwish_counts_all[g.id]] }.flatten ]
    top_ten = @playwish_counts.sort_by{|gid,n| n}.reverse[0..9]
    @most_desired_games = top_ten.map { |gid, n| 
      @player.owned_games.detect{|g| g.id == gid}
    }
    @playwish_counts = Hash[* top_ten.flatten]

  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: 'Player was successfully created.' }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: 'Player was successfully updated.' }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player.destroy
    respond_to do |format|
      format.html { redirect_to players_url, notice: 'Player was successfully destroyed.' }
      format.json { head :no_content }
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

  
  def link_with_bgg_account
    logger.debug("in link_with_bgg_account #{params.require(:id)}")
    @player = Player.find(params.require(:id)[:id])
    if @player.update(params.require(:bgg_username))
      redirect_to @player, notice: 'Player bgg_username successfully updated'
    else
      redirect_to @player, notice: "Player bgg_username update failed.  Errors: #{@player.errors}"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:bgg_username, :bgg_user_id, :meetup_username, :meetup_user_id, :meetup_bio)
    end
end
