require 'open-uri'

class ApiController < ApplicationController
  @@token = Rails.application.secrets.api_token

  def get_agencies
    request_url = "http://services.my511.org/Transit2.0/GetAgencies.aspx?token=#{@@token}"
    @agencies = search_for_key(parse_request(request_url), "Agency")
    respond_to do |format|
      format.js {}
    end
  end

  def get_routes
    @agency = params[:name]
    request_url = "http://services.my511.org/Transit2.0/GetRoutesForAgency.aspx?token=#{@@token}&agencyName=#{@agency}"
    @routes = search_for_key(parse_request(request_url), "Route")
    puts JSON.pretty_generate(@routes)

    respond_to do |format|
      format.js {}
    end
  end

  def get_stops
    @agency = params[:agency]
    @route = params[:route]
    @direction = params[:direction] ? "~" + params[:direction] : ""

    request_url = "http://services.my511.org/Transit2.0/GetStopsForRoute.aspx?token=#{@@token}&routeIDF=#{@agency}~#{@route}#{@direction}"
    @stops = search_for_key(parse_request(request_url), "Stop")
    puts JSON.pretty_generate(@stops)

    respond_to do |format|
      format.js {}
    end
  end

  def get_departures

  end

  private
    def parse_request(url)
      return Crack::XML.parse(open(url).read)
    end

    # This helper method makes it simpler to traverse json
    # response for both directional and non-directional routes
    def search_for_key(json_obj, tkey)
      json_obj.each do |key, value|
        return value if key === tkey
        if value.respond_to?(:keys)
          return search_for_key(value, tkey)
        end
      end
      return false
    end


end
