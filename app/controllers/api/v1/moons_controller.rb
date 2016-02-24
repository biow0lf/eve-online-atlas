module Api
  module V1
    class MoonsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        mp = moon_params
        solarsystem = Solarsystem.find_by(solarSystemID: mp[:solarsystem_id])
        result = nil
        planet = nil
        unless solarsystem.nil?
          planet = solarsystem.planets.find_by(itemID: mp[:planet_id])
          result = planet.moons unless planet.nil?
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

      def show
        # permit proper parameters
        mp = moon_params
        solarsystem = Solarsystem.find_by(solarSystemID: mp[:solarsystem_id])
        result = nil
        planet = nil
        moon = nil

        # Make sure solarsystem is not nil
        unless solarsystem.nil?
          planet = solarsystem.planets.find_by(itemID: mp[:planet_id])
          # Make sure planet is not nil
          unless planet.nil?
            moon = planet.moons.find_by(itemID: params[:id])
            result = moon.as_json
            unless moon.nil?
              result['statistics'] = moon.celestialstatistic
              result['materials'] = moon.moonmaterial
            end
          end
        end

        status = 200
        if solarsystem.nil?
          status = 400
          result = { error: 'Invalid solarSystemID', status: status }
        elsif planet.nil?
          status = 400
          result = { error: 'Invalid itemID for planet', status: status }
        elsif moon.nil?
          status = 400
          result = { error: 'Invalid itemID for moon', status: status }
        end

        render json: result.as_json, status: status
      end

      private

      def moon_params
        params.permit(:id, :solarsystem_id, :planet_id)
      end
    end
  end
end
