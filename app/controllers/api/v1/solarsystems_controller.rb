module Api
  module V1
    class SolarsystemsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        # permit proper parameters
        ssp = solarsystem_params

        # if there is a :name parameter, use that to find solarsystem
        # else return all solarsystems
        solarsystem = if ssp.key?(:name)
                        Solarsystem.find_by(solarSystemName: ssp[:name])
                      else
                        Solarsystem.all
                      end

        render json: solarsystem.to_json
      end

      def show
        # permit proper parameters
        ssp = solarsystem_params

        # find solarsystem by id
        result = Solarsystem.find_by(solarSystemID: ssp[:id])

        # make sure solarsystem is not nil before finding planetIDs
        unless result.nil?
          planet_ids = result.planets.pluck(:itemID)
          result = result.as_json
          result['planetIDs'] = planet_ids
        end

        status = 200
        if result.nil?
          status = 400
          result = { error: 'Invalid solarSystemID', status: status }
        end

        render json: result, status: status
      end

      private

      def solarsystem_params
        params.permit(:id, :name)
      end
    end
  end
end
