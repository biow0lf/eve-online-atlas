module Api
  module V1
    class StationsController < ApiController
      respond_to :json
      before_action :find_solarsystem, :find_stations

      def index
        render json: @solarsystem.stations.to_json
      end

      def show
        result = {}
        result = @station.as_json
        result['type'] = @station.stationoperation
        result['services'] = @station.stationservices
        render json: result.as_json
      end

      private

      def find_solarsystem
        @solarsystem = Solarsystem.find(params[:solarsystem_id])
      end

      def find_stations
        if params[:id]
         @station = @solarsystem.stations.find(params[:id])
        else
         @station = @solarsystem.stations
        end
      end
    end
  end
end