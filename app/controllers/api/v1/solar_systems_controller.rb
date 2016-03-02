module Api
  module V1
    class SolarSystemsController < ApiController
      respond_to :json
      before_action :find_solarsystem

      def index
        return render json: @solarsystem if @solarsystem
        return render json: [], status: :bad_request if params[:name]
        render json: SolarSystem.all
      end

      def show
        planet_ids = @solarsystem.planets.pluck(:itemID)
        result = @solarsystem.as_json
        result['class'] = @solarsystem.wormholeClass.wormholeClassID
        result['region'] = @solarsystem.region
        result['costIndexes'] = @solarsystem.systemCostIndex
        result['constellation'] = @solarsystem.constellation
        result['stationIDs'] = @solarsystem.stations.pluck(:stationID)
        if result['stationIDs'].empty?
          result['stationIDs'] = @solarsystem.playerStations.pluck(:stationID)
        end
        result['planetIDs'] = planet_ids
        render json: result
      end

      def neighbors
        render json: @solarsystem.toSolarSystems
      end

      private

      def find_solarsystem
        return @solarsystem = SolarSystem.find_by(solarSystemName: params[:name]) if params.key?(:name)
        @solarsystem = SolarSystem.find(params[:id]) if params[:id]
      end
    end
  end
end
