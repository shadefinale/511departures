require 'open-uri'

class ApiController < ApplicationController
  @@token = Rails.application.secrets.api_token

  def get_agencies
    request_url = "http://services.my511.org/Transit2.0/GetAgencies.aspx?token=#{@@token}"
    @agencies = search_for_key(parse_request(request_url), "Agency")
    # All results are coerced into an array in case they are only one value.
    @agencies = [@agencies] unless @agencies.kind_of?(Array)
    respond_to do |format|
      format.js {}
    end
  end

  def get_routes
    @agency = params[:name]
    request_url = "http://services.my511.org/Transit2.0/GetRoutesForAgency.aspx?token=#{@@token}&agencyName=#{@agency}"
    @routes = search_for_key(parse_request(request_url), "Route")
    @routes = [@routes] unless @routes.kind_of?(Array)
    respond_to do |format|
      format.js {}
    end
  end

  def get_stops
    @agency = params[:agency]
    @route = params[:route]
    @direction = params[:direction] ? "~" + params[:direction] : ""

    request_url = "http://services.my511.org/Transit2.0/GetStopsForRoute.aspx?token=#{@@token}&routeIDF=#{@agency}~#{@route}#{@direction}"
    p parse_request(request_url)
    @stops = search_for_key(parse_request(request_url), "Stop") || []
    @stops = [@stops] unless @stops.kind_of?(Array)
    puts JSON.pretty_generate(@stops)
    respond_to do |format|
      format.js {}
    end
  end

  def get_departures
    @stop_code = params[:stop_code]

    request_url = "http://services.my511.org/Transit2.0/GetNextDeparturesByStopCode.aspx?token=#{@@token}&stopcode=#{@stop_code}"
    @departures = search_for_key(parse_request(request_url), "Route")
    @departures = [@departures] unless @departures.kind_of?(Array)
    # puts JSON.pretty_generate(@departures)
    respond_to do |format|
      format.js {}
    end
  end

  private
    def parse_request(url)
      return Crack::XML.parse(open(url).read)
    end

    # This helper method makes it simpler to traverse json
    # response for both directional and non-directional routes
    helper_method :search_for_key
    def search_for_key(json_obj, tkey)
      ret_val = false
      json_obj.each do |key, value|
        p key, tkey
        if key === tkey && !ret_val
          return value
        elsif value.respond_to?(:keys)
          ret_val = search_for_key(value, tkey)
        end
      end
      return ret_val
    end


end
