module Api
  module V1
    class MoonsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_planet, :find_moon

      def index
        render json: @planet.moons.to_json
      end

      def show
        result = @moon.as_json
        result['statistics'] = @moon.celestialstatistic
        result['materials'] = @moon.moonmaterial
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = Solarsystem.find(params[:solarsystem_id])
      end

      def find_planet
        @planet = @solarsystem.planets.find(params[:planet_id])
      end

      def find_moon
        @moon = @planet.moons.find(params[:id]) if params[:id]
      end
    end
  end
end
