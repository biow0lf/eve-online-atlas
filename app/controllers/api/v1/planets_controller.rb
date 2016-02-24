module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        pp = planet_params
        solarsystem = Solarsystem.find_by(solarSystemID: pp[:solarsystem_id])
        result = nil
        result = solarsystem.planets unless solarsystem.nil?

        status = 200
        if solarsystem.nil?
          status = 400
          result = { error: 'Invalid solarSystemID', status: status }
        end

        render json: result, status: status
      end

      def show
        # permit proper parameters
        pp = planet_params
        solarsystem = Solarsystem.find_by(solarSystemID: pp[:solarsystem_id])
        result = nil
        planet = nil

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

        status = 200
        if solarsystem.nil?
          status = 400
          result = { error: 'Invalid solarSystemID', status: status }
        elsif planet.nil?
          status = 400
          result = { error: 'Invalid itemID for planet', status: status }
        end

        render json: result, status: status
      end

      private

      def planet_params
        params.permit(:id, :solarsystem_id)
      end
    end
  end
end
