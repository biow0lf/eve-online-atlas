module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_planet

      def index
        render json: @solarsystem.planets.to_json
      end

      def show
        result = @planet.as_json
        moon_ids = @planet.moons.pluck(:itemID)
        result['type'] = Item.find_by(typeID: @planet.typeID).typeName[/\(([^)]+)\)/, 1]
        result['moonIDs'] = moon_ids
        result['statistics'] = @planet.celestialstatistic
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = Solarsystem.find(params[:solarsystem_id])
      end

      def find_planet
        @planet = @solarsystem.planets.find(params[:id]) if params[:id]
      end
    end
  end
end
