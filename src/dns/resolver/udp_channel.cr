class DNS::Resolver::UDP_Channel < DNS::Resolver::Channel
	@socket : UDPSocket
	@buffer = Bytes.new(512)
	def initialize( hostname : String, port : Number )
		@socket = UDPSocket.new
		@socket.connect( hostname, port )
	end
	def initialize( @socket )
	end
	def send_request( msg : DNS::Message )
		@socket.send( msg.encode() )
	end
	def get_response() : DNS::Message
		size,addr = @socket.receive(@buffer)
		return Message.decode(@buffer[0,size])
	end
end
