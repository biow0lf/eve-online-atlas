module Api
  module V1
    class SolarsystemsController < ApiController
      respond_to :json
      before_action :find_solarsystem

      def index
        return render json: @solarsystem if @solarsystem
        return render json: [], status: :bad_request if params[:name]
        render json: Solarsystem.all
      end

      def show
        planet_ids = @solarsystem.planets.pluck(:itemID)
        result = @solarsystem.as_json
        result['class'] = @solarsystem.wormholeclass.wormholeClassID
        result['region'] = @solarsystem.region
        result['costIndexes'] = @solarsystem.systemcostindex
        result['constellation'] = @solarsystem.constellation
        result['stationIDs'] = @solarsystem.stations.pluck(:stationID)
        if result['stationIDs'].empty?
          result['stationIDs'] = @solarsystem.playerstations.pluck(:stationID)
        end
        result['planetIDs'] = planet_ids
        render json: result
      end

      def get_neighbors
        render json: @solarsystem.tosolarsystems
      end

      private

      def find_solarsystem
        return @solarsystem = Solarsystem.find_by(solarSystemName: params[:name]) if params.key?(:name)
        @solarsystem = Solarsystem.find(params[:id]) if params[:id]
      end
    end
  end
end
