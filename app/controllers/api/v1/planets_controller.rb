module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_planet

      def index
        render json: @solarsystem.planets.to_json if @solarsystem
      end

      def show
        return render json: { error: 'Planet not found', status: :bad_request }, status: :bad_request unless @solarsystem && @planet
        result = @planet.as_json
        moon_ids = @planet.moons.pluck(:itemID)
        result['type'] = Item.find_by(typeID: @planet.typeID).typeName[/\(([^)]+)\)/, 1]
        result['moonIDs'] = moon_ids
        result['statistics'] = @planet.celestialstatistic
        render json: result.as_json
      end

      private

      def planet_params
        params.permit(:id, :solarsystem_id)
      end

      def find_solarsystem
        @pp = planet_params
        @solarsystem = Solarsystem.find(@pp[:solarsystem_id]) if @pp[:solarsystem_id]
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Solarsystem not found', status: :bad_request }, status: :bad_request
      end

      def find_planet
        @planet = @solarsystem.planets.find(@pp[:id]) if @pp[:id]
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Planet not found', status: :bad_request }, status: :bad_request
      end
    end
  end
end
