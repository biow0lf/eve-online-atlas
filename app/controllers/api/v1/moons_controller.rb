module Api
  module V1
    class MoonsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        render json: Solarsystem.all.to_json
      end

      def show
        # find planets by solarSystemID as int
        planet = Solarsystem.find_by(solarSystemID: params[:solarsystem_id].to_i).planets.find_by(itemID: params[:planet_id].to_i)

        moons = planet.moons.where(itemID: params[:id].to_i)

        result = []
        # for each planet in the relationship
        moons.each do |a|
          tmp = a.as_json

          tmp['statistics'] = a.celestialstatistic

          # push the result to the output
          result.push(tmp)
        end

        # return the output
        render json: moons.as_json
      end
    end
  end
end
