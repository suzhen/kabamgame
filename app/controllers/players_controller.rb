class PlayersController < ApplicationController

  def index
    @players=User.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cities }
    end 
  end

end
