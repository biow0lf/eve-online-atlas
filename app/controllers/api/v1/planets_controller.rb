module Api
  module V1
    class PlanetsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index

        render json: solarsystem.to_json
      end

      def show
		# permit proper parameters
        ssp = planet_params
	  	  
        # find planets by solarSystemID as int
        planet = Solarsystem.find_by(solarSystemID: ssp[:solarsystem_id]).planets.find_by(itemID: params[:id].to_i)
		
		# make sure planet is not nil before finding moonIDs
        unless planet.nil?
          moon_ids = planet.moons.pluck(:itemID)
          result = planet.as_json
          result['moonIDs'] = moon_ids
		  result['type'] = Item.find_by(typeID: planet.typeID).typeName[/\(([^)]+)\)/, 1]
          result['statistics'] = planet.celestialstatistic
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
