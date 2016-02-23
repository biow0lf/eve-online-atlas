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
			planets = Solarsystem.find_by(solarSystemID: params[:solarsystem_id].to_i).planets.where(itemID: params[:planet_id].to_i)
			# create output array
			result = []
			# for each planet in the relationship
			planets.each do |a|
				# dump the planet to a tmp variable as json
				tmp = a.moons.where(itemID: params[:id].to_i)

				# push the result to the output
				result.push(tmp)
			end
			

			# return the output
			render json: result.as_json
       
      end
    end
  end
end
