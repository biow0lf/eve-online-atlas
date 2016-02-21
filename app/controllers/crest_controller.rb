class CrestController < ApplicationController
  include HTTParty

  def index
  end

  def thera
    system = params[:system]
    response = HTTParty.get("https://eve-scout.com/api/wormholes?systemSearch=#{system}")
    render json: response.body
  end
end
