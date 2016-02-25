module Api
  module V1
    class MoonsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_planet, :find_moon

      def index
        render json: @planet.moons.to_json if @planet
      end

      def show
        result = @moon.as_json
        result['statistics'] = @moon.celestialstatistic
        result['materials'] = @moon.moonmaterial
        render json: result.as_json, status: status
      end

      private

      def moon_params
        params.permit(:id, :solarsystem_id, :planet_id)
      end

      def find_solarsystem
        @mp = moon_params
        @solarsystem = Solarsystem.find(@mp[:solarsystem_id]) if @mp[:solarsystem_id]
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Solarsystem not found', status: :bad_request }, status: :bad_request
      end

      def find_planet
        @planet = @solarsystem.planets.find(@mp[:planet_id]) if @mp[:planet_id]
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Planet not found', status: :bad_request }, status: :bad_request
      end

      def find_moon
        @moon = @planet.moons.find(@mp[:id]) if @mp[:id]
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Moon not found', status: :bad_request }, status: :bad_request
      end
    end
  end
end
