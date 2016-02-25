module Api
  module V1
    class SolarsystemsController < ApiController
      respond_to :json
      before_action :find_solarsystem

      def index
        return render json: @solarsystem.to_json if @solarsystem
        render json: Solarsystem.all
      end

      def show
        return render status: :bad_request unless @solarsystem
        planet_ids = @solarsystem.planets.pluck(:itemID)
        result = @solarsystem.as_json
        result['class'] = @solarsystem.wormholeclass.wormholeClassID
        result['planetIDs'] = planet_ids
        render json: result
      end

      private

      def solarsystem_params
        params.permit(:id, :name)
      end

      def find_solarsystem
        @ssp = solarsystem_params
        if @ssp.has_key?(:name)
          @solarsystem = Solarsystem.find_by(solarSystemName: @ssp[:name])
        else
          @solarsystem = Solarsystem.find(@ssp[:id]) if @ssp[:id]
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Solarsystem not found', status: :bad_request }, status: :bad_request
      end
    end
  end
end
