require "socket"

class DNS::Server
	class Request
		property message : DNS::Message = DNS::Message.new()
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
			loop {
				# Get the request
				if !(req=get_request()).nil?
					# Send to the main thread to process
					@request_channel.send(req)

					# Send any responses that are ready
					while !@response_channel.empty?
						res = @request_channel.receive

						send_response( res )
					end
				end
			}
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
	end
	class UDPListener < Listener
		@socket : UDPSocket
		@buffer = Bytes.new(4096)
		def initialize(@socket)
		end

		def get_request() : Request?
			size,addr = @socket.receive(@buffer)

			# Create a new request
			req = Request.new(addr)
			req.message = DNS::Message.decode(@buffer[0,size])
			req.remote_address = addr

			return req
		end
		def send_response( req : Request )
			if !(ra=req.remote_address).nil?
				@socket.send( req.message.encode(), ra )
			end
		end
	end

	@listeners = [] of Listener

	def initialize( udp_addr = "localhost", udp_port = 56, tcp_addr = "localhost", tcp_port = 53 )
		# Setup UDP listener
		l = UDPListener.new(sock=UDPSocket.new)
		sock.bind( udp_addr, udp_port )
		@listeners.push(l)

		# Setup TCP listener
		l = TCPListener.new(TCPServer.new( tcp_addr, tcp_port ))
		@listeners.push(l)
	end
	def run()
		# Startup fibers for each listener
		@listeners.each {|l|
			spawn do
				l.run
			end
		}

		# event processing loop
		loop do
			@listeners.each {|l|
				while !l.request_channel.empty?
					req = l.request_channel.receive
					process_request(req)
					l.response_channel.send(req)
				end
			}
		end
	end

	def process_request( req : Request )
		puts req.inspect
	end
end

