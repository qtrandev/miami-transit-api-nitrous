class MiamiDadeBusTranslator
  def initialize(bus_xml)
    @bus_xml = bus_xml
  end

  def to_gtfs
    message.encode
  end

  def to_hash
    message.to_hash
  end

  private
  def message
    return @message if defined? @message

    @message = FeedMessage.new.tap do |msg|
      msg.header = header
      msg.entity = entities
    end
  end

  def header
    @header ||= FeedHeader.new.tap do |head|
      head.gtfs_realtime_version = '1.0'
    end
  end

  def document
    @document ||= Nokogiri::XML.parse @bus_xml
  end

  def entities
    document.css('Record').map do |record|
      bus_hash = record.children.map do |c|
        { c.name => c.content }
      end.inject(&:merge)

      FeedEntity.new.tap do |entity|
        entity.id = "#{ bus_hash['BusID'] }_#{ bus_hash['BusName']}"


        entity.trip_update = TripUpdate.new.tap do |tu|
          tu.trip = TripDescriptor.new.tap do |trip|
            trip.route_id = bus_hash['RouteID']
            trip.trip_id = bus_hash['TripID']
          end
#          tu.stop_time_update = StopTimeUpdate.new.tap do |stu|
#            stu.stop_sequence = 30
#            stu.departure = TripUpdate::StopTimeEvent.new.tap do |dep|
#              dep.delay = 300
#            end
#          end
        end

=begin
        entity.vehicle = VehiclePosition.new.tap do |vp|
          vp.trip = TripDescriptor.new.tap do |trip|
            trip.route_id = bus_hash['RouteID']
            trip.trip_id = bus_hash['TripID']
          end
          vp.position = Position.new.tap do |pos|
            pos.latitude = bus_hash['Latitude'].to_f
            pos.longitude = bus_hash['Longitude'].to_f
          end
          vp.current_stop_sequence = 30
        end
=end
      end
    end
  end
end
