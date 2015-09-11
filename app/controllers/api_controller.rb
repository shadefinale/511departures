# Open URI is required in order to make get requests through ruby.
require 'open-uri'

# The api controller is in charge of making requests on behalf of the front-end.
# This is both to keep our api token secret, but also so we can edit our request
# flow later one much easier.
# For example, say we want to cache the results of api requests
# with something like Redis: it'll be trivial to add it in here compared
# to using xhr requests on the front end.

# The api controller is remote-form style only.
# The basic flow of any request made through this api is as follows:
# 1. Make an API request
# 2. Take the response and convert it to json. Then, search this json for
# 3. specific keys based on what action we're doing.
# 4. After finding the value we want and doing our best to normalize it,
# 5. Render a js.erb template that will display this information to the user.

# Note: The majority of animations are done through the AnimationHandler module.
class ApiController < ApplicationController
  @@token = Rails.application.secrets.api_token

  def get_agencies
    request_url = "http://services.my511.org/Transit2.0/GetAgencies.aspx?token=#{@@token}"
    @agencies = search_for_key(parse_request(request_url), "Agency")
    # All results are coerced into an array in case they are only one value.
    @agencies = [@agencies] unless @agencies.kind_of?(Array)

    # I'm not impressed with the api's handling of the last
    # few agencies (nearly no stops being tracked for some reason)
    # so I cut them out here.
    @agencies = @agencies[0..-5]
    respond_to do |format|
      format.js {}
    end
  end

  # Gets routes in a way that lets us handle both directional and non-directional routes.
  def get_routes
    @agency = params[:name]
    request_url = "http://services.my511.org/Transit2.0/GetRoutesForAgency.aspx?token=#{@@token}&agencyName=#{@agency}"
    @routes = search_for_key(parse_request(request_url), "Route")
    @routes = [@routes] unless @routes.kind_of?(Array)
    respond_to do |format|
      format.js {}
    end
  end

  # Gets stops in a way that lets us handle both directional and non-directional stops.
  # If the response returns no stops (Why do they even show routes that do not track
  # stops?), we return empty array.
  def get_stops
    @agency = params[:agency]
    @route = params[:route]
    @direction = params[:direction] ? "~" + params[:direction] : ""

    request_url = "http://services.my511.org/Transit2.0/GetStopsForRoute.aspx?token=#{@@token}&routeIDF=#{@agency}~#{@route}#{@direction}"
    p parse_request(request_url)
    @stops = search_for_key(parse_request(request_url), "Stop") || []

    @stops = [@stops] unless @stops.kind_of?(Array)
    respond_to do |format|
      format.js {}
    end
  end

  # Departures are handled the same as stops and routes.
  # However, sometimes the response is nothing, so we return empty array
  # in this case.
  def get_departures
    @stop_code = params[:stop_code]

    request_url = "http://services.my511.org/Transit2.0/GetNextDeparturesByStopCode.aspx?token=#{@@token}&stopcode=#{@stop_code}"
    @departures = search_for_key(parse_request(request_url), "Route")
    @departures = [] unless @departures
    @departures = [@departures] unless @departures.kind_of?(Array)
    respond_to do |format|
      format.js {}
    end
  end

  private
    # This project uses the 'crack' gem to convert the XML response of the
    # api into json. No real reason to do this except to make it simpler
    # to work with on my end.
    def parse_request(url)
      return Crack::XML.parse(open(url).read)
    end

    # This helper method makes it simpler to traverse json
    # response for both directional and non-directional routes
    # Since directional and non-directional routes return different kinds
    # of nested json structures, this just lets us search for the key
    # we actually care about instead of writing many conditionals

    # Returns the first matching key found in the given nested json object.
    helper_method :search_for_key
    def search_for_key(json_obj, tkey)
      ret_val = false
      json_obj.each do |key, value|
        if key === tkey && !ret_val
          return value
        elsif value.respond_to?(:keys)
          ret_val = search_for_key(value, tkey)
        end
      end
      return ret_val
    end


end
