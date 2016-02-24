module Api
  module V1
    class MoonsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        render json: Solarsystem.find_by(solarSystemID: params[:solarsystem_id]).planets.find_by(itemID: params[:planet_id]).moons
      end

      def show
        # permit proper parameters
        mp = moon_params
        solarsystem = Solarsystem.find_by(solarSystemID: mp[:solarsystem_id])
        result = {}

        # Make sure solarsysetm is not nil
        unless solarsystem.nil?
          planet = solarsystem.planets.find_by(itemID: mp[:planet_id])

          # Make sure planet is not nil
          unless planet.nil?
            moons = planet.moons.find_by(itemID: params[:id])
            result = moons.as_json
            unless moons.nil?
              result['statistics'] = moons.celestialstatistic
              result['materials'] = moons.moonmaterial
            end
          end
    end

        # return the output
        render json: result
       end

      private

      def moon_params
        params.permit(:id, :solarsystem_id, :planet_id)
      end
    end
  end
end
