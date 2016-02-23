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
        if ssp.has_key?(:name)
          solarsystem = Solarsystem.find_by(solarSystemName: ssp[:name])
        else
          solarsystem = Solarsystem.all
        end

        render json: solarsystem.to_json
      end

      def show
        # permit proper parameters
        ssp = solarsystem_params

        # find solarsystem by id
        solarsystem = Solarsystem.find_by(solarSystemID: ssp[:id])

        # make sure solarsystem is not nil before finding planetIDs
        unless solarsystem.nil?
          planet_ids = solarsystem.planets.pluck(:itemID)
          solarsystem = solarsystem.as_json
          solarsystem['planetIDs'] = planet_ids
        end

        render json: solarsystem.as_json
      end

      private

      def solarsystem_params
        params.permit(:id, :name)
      end
    end
  end
end
