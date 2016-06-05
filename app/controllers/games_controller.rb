class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy]


  # GET /games
  # GET /games.json
  def index
    ps = params.permit(:term, :page)
    if (ps[:term])
      @games = Game.search(term: ps[:term], limit: 10, offset: ps[:page] || 0)
    else
      #TODO: allow only numeric param
      @games = Game.list_a_page({offset: ps[:page], limit: 20})
    end
  end



  def rare_games
    @games = Game.find_rare_games()
    render 'index'
  end

  def desired_games
    @games = Game.find_desired_games()
    render 'index'
  end
  
  #GET /game_names
  def game_names
    ps = params.permit(:term)
    if (ps[:term]) 
      @games = Game.search(ps)
    else
      @games = []
    end
    render json: @games.map(&:name)
  end


  # GET /games/1
  # GET /games/1.json
  def show
    @rating_players = @game.rating_players.select('players.*, ratings.rating').order('ratings.rating desc, players.meetup_username').where('ratings.rating > 6').limit(20)
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:name, :bgg_game_id)
    end
end
