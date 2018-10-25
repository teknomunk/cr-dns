require "socket"

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
	abstract class Listener
		property request_channel = Channel(Request).new()
		property response_channel = Channel(Request).new()

		abstract def get_request() : Request?
		abstract def send_response( req : Request )

		def run()
			puts "Starting listener loop"
			spawn do
				loop {
					begin
						# Get the request
						if !(req=get_request()).nil?
							# Send to the main thread to process
							@request_channel.send(req)
						end
					rescue e
						# Report server error
						puts "Caught error: #{e}"
						if req
							req.message.response_code = Message::ResponseCode::ServerFailure
							send_response(req)
						end
					end
				}
			end
			spawn do
				loop {
					res = @response_channel.receive
					send_response(res)
				}
			end
		end
	end

	class TCPListener < Listener
		@socket : TCPSocket

		def initialize(@socket)
		end

		def get_request() : Request?
			if !(s=@socket.accept?).nil?
				req = Request.new()
				req.socket = s
				return req
			end
			return nil
		end
		def send_response( req : Request )
			if !(sock=req.socket).nil?
				sock.send( req.message.encode() )
			end
		end
	end # end TCPListener < Listener

	class UDPListener < Listener
		@socket : UDPSocket
		@buffer = Bytes.new(4096)
		def initialize(@socket)
		end

		def get_request() : Request?
			size,addr = @socket.receive(@buffer)
			#puts "Received request:"
			#puts @buffer[0,size].inspect

			# Create a new request
			req = Request.new(addr)
			req.message = Message.decode(@buffer[0,size])
			req.remote_address = addr

			return req
		end
		def send_response( req : Request )
			if !(ra=req.remote_address).nil?
				response = req.message.encode()
				#puts "sending response: #{response}"
				#puts req.message.inspect
				@socket.send( response, ra )
			else
				puts "Unable to send request, no remote address #{req.remote_address}"
			end
		end
	end # class UDPListener < Listener


	@listeners = [] of Listener
	getter channel_listener = ChannelListener.new()

	def initialize()
		@listeners.push(@channel_listener)
	end
	def listen_udp( addr, port )
		# Setup UDP listener
		l = UDPListener.new(sock=UDPSocket.new)
		sock.bind( addr, port )
		@listeners.push(l)
	end
	def listen_tcp( addr, port )
		# Setup TCP listener
		l = TCPListener.new(TCPServer.new( addr, port ))
		@listeners.push(l)
	end


	def run()
		raise "DNS::Server requires at least one listener" if @listeners.size == 0

		# Startup fibers for each listener
		@listeners.each {|l| l.run }

		# event processing loop
		puts "Entering event processing loop"
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
					@{{type.id}}_routes.find {|route| route.try_dispatch(req,q) }
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
	end
end

require "./server/*"

