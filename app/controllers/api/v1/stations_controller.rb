module Api
  module V1
    class StationsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_stations

      def index
        stations = @solarsystem.stations.order(:stationID)
        result = []
        stations.each do |station|
          to_push = station.as_json
          to_push['type'] = station.stationOperation
          to_push['services'] = station.stationServices.pluck(:serviceName)
          result << to_push
        end
        render json: result
      end

      def show
        result = @station.as_json
        result['type'] = @station.stationOperation
        result['services'] = @station.stationServices
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = SolarSystem.find(params[:solar_system_id])
      end

      def find_stations
        @station = if params[:id]
                     @solarsystem.stations.find(params[:id])
                   else
                     @solarsystem.stations
                   end
      end
    end
  end
end
