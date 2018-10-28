class DNS::Server::UDPListener < DNS::Server::Listener
	@socket : UDPSocket
	@buffer = Bytes.new(4096)
	def initialize( addr : String, port : Number )
		@socket = UDPSocket.new()
		@socket.bind(addr,port)
	end

	def get_request() : Request?
		size,addr = @socket.receive(@buffer)

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
