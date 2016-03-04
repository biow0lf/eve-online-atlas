module Api
  module V1
    class RegionsController < ApiController
      respond_to :json
      before_action :find_region

      def index
        return render json: @region if @region
        return render json: [], status: :bad_request if params[:name]
        render json: Region.all
      end

      def show
        solar_system_ids = @region.solarSystems.pluck(:solarSystemID)
        constellation_ids = @region.constellations.pluck(:constellationID)
        result = @region.as_json
        result['constellationIDs'] = constellation_ids
        result['solarSystemIDs'] = solar_system_ids
        render json: result
      end

      private

      def find_region
        if params.key?(:name)
          # check first for an exact match
          @region = Region.find_by(regionName: params[:name])
          # else try to match via LIKE
          @region ||= Region.where('regionName LIKE ?', '%' + params[:name] + '%').first
        elsif params[:id]
          @region = Region.find(params[:id])
        end
      end
    end
  end
end
