require "socket"
class DNS::Server
end

require "./server/listener.cr"

class DNS::Server
	class Request
		property message : Message = Message.new()
		property remote_address : Socket::IPAddress?
		property socket : Socket?

		def initialize()
		end
		def initialize( @remote_address )
		end
	end

	@listeners = [] of Listener
	@zones = [] of Zone
	getter channel_listener = ChannelListener.new()

	def initialize()
		@listeners.push(@channel_listener)
	end
	def add_listener( l : DNS::Server::Listener )
		@listeners.push(l)
	end
	def listen_udp( addr : String, port : Number )
		@listeners.push( DNS::Server::UDPListener.new( addr, port ) )
	end
	def listen_tcp( addr : String, port : Number )
		@listeners.push( DNS::Server::TCPListener.new( addr, port ) )
	end

	def run()
		raise "DNS::Server requires at least one listener" if @listeners.size == 0

		# Startup fibers for each listener
		@listeners.each {|l| l.run }

		# event processing loop
		#puts "Entering event processing loop"
		loop do
			@listeners.each {|l|
				while !l.request_channel.empty?
					req = l.request_channel.receive
					process_request(req)
					l.response_channel.send(req)
				end
			}
			sleep 0.1
		end
	end

	def process_request( req : Request )
		{% begin %}
		case req.message.query_type
			{% for type,code in Message::QUERY_TYPES %}
			when Message::{{code.id}}
				req.message.questions.each {|q|
					@{{type.id}}_routes.find {|route| route.try_dispatch(req,q) } ||
					@zones.find {|zone| zone.try_dispatch(req,q) }
				}
			{% end %}
			else
				req.message.response_code = Message::ResponseCode::NotImplemented
		end
		{% end %}
	end

	{% for type,code in Message::QUERY_TYPES %}
		@{{type.id}}_routes = [] of Route
		def {{type.id}}( domain : String, type : RR::Type = RR::ANY, cls : RR::Cls = RR::IN, &block : Request,RR -> _ )
			@{{type.id}}_routes.push( Route.new( domain, type, cls, &block ) )
		end
	{% end %}

	def add_zone( zone : DNS::Zone )
		@zones.push(zone)
	end
end

require "./server/*"

