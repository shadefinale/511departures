require 'open-uri'

class ApiController < ApplicationController
  @@token = Rails.application.secrets.api_token

  def get_agencies
    request_url = "http://services.my511.org/Transit2.0/GetAgencies.aspx?token=#{@@token}"
    @agencies = parse_request(request_url)["RTT"]["AgencyList"]["Agency"]
    respond_to do |format|
      format.js {}
    end
  end

  def get_routes
    agency_name = params[:name]
    request_url = "http://services.my511.org/Transit2.0/GetRoutesForAgency.aspx?token=#{@@token}&agencyName=#{agency_name}"
    @routes = parse_request(request_url)["RTT"]["AgencyList"]["Agency"]["RouteList"]["Route"]#["AgencyList"]["Agency"]
    puts JSON.pretty_generate(@routes)

    respond_to do |format|
      format.js {}
    end
  end

  def get_stops

  end

  def get_departures

  end

  private
    def parse_request(url)
      return Crack::XML.parse(open(url).read)
    end


end
