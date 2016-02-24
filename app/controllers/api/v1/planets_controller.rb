module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        render json: Solarsystem.find_by(solarSystemID: params[:solarsystem_id]).planets
      end

      def show
        # permit proper parameters
        pp = planet_params
        solarsystem = Solarsystem.find_by(solarSystemID: pp[:solarsystem_id])
        result = {}

        # Make sure solarsysetm is not nil
        unless solarsystem.nil?
          planet = solarsystem.planets.find_by(itemID: params[:id])
          result = planet.as_json
          # Make sure planet is not nil
          unless planet.nil?
            moon_ids = planet.moons.pluck(:itemID)
            result['type'] = Item.find_by(typeID: planet.typeID).typeName[/\(([^)]+)\)/, 1]
            result['moonIDs'] = moon_ids
            result['statistics'] = planet.celestialstatistic
          end
    end

        # return the output
        render json: result
     end

      private

      def planet_params
        params.permit(:id, :solarsystem_id)
      end
    end
  end
end
