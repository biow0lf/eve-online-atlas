module Api
  module V1
    class SolarsystemsController < ApiController
      respond_to :json
      # after_action :verify_authorized, except: :index
      # after_action :verify_policy_scoped, only: :index

      def index
        render json: Solarsystem.all.to_json
      end

      def show
        solarsystem = if params[:id].to_i > 0
                        # if actually an item id, search by id
                        Solarsystem.find_by(solarSystemID: params[:id].to_s)
                      else
                        # else search by name
                        Solarsystem.find_by(solarSystemName: params[:id])
                      end
        render json: solarsystem.to_json
      end
    end
  end
end
