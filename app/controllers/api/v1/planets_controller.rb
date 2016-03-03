module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_planet

      def index
        planets = @solarsystem.planets.order(:celestialIndex)
        result = []
        planets.each do |planet|
          to_push = planet.as_json
          to_push['type'] = Item.find_by(typeID: planet.typeID).typeName[/\(([^)]+)\)/, 1]
          to_push['moonIDs'] = planet.moons.pluck(:itemID)
          to_push['materials'] = planet.planetMaterials
          to_push['statistics'] = planet.celestialStatistic
          result << to_push
        end
        render json: result
      end

      def show
        result = @planet.as_json
        moon_ids = @planet.moons.pluck(:itemID)
        result['type'] = Item.find_by(typeID: @planet.typeID).typeName[/\(([^)]+)\)/, 1]
        result['moonIDs'] = moon_ids
        result['statistics'] = @planet.celestialStatistic
        result['materials'] = @planet.planetMaterials.pluck(:materialType)
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = SolarSystem.find(params[:solar_system_id])
      end

      def find_planet
        @planet = @solarsystem.planets.find(params[:id]) if params[:id]
      end
    end
  end
end
