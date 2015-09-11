module RoutePartialHelper
  def build_stop_link(route, agency)
    base_link = "#{route['Name']}"
    link = ""
    directions = route["RouteDirectionList"]
    if directions && directions["RouteDirection"] && directions["RouteDirection"].kind_of?(Array)
      directions["RouteDirection"].each do |direction|
        link += link_to("#{route["Name"]} - #{direction["Name"]}", get_stops_path(agency, route["Name"], direction["Code"]), remote: true)
        link += "<br>"
      end
      return link.html_safe
    elsif directions && directions["RouteDirection"]
      return link_to("#{route["Name"]} - #{directions["RouteDirection"]["Name"]}", get_stops_path(agency, directions["RouteDirection"]["Name"]), remote: true).html_safe
    end
    return link_to("#{route["Name"]}", get_stops_path(agency, route["Code"]), remote: true)
  end
end
