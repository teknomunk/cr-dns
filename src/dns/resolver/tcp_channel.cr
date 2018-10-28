class DNS::Resolver::TCPChannel < DNS::Resolver::Channel
	@socket : TCPSocket
	def initialize( hostname : String, port : Number )
		@socket = TCPSocket.new(hostname,port)
	end
	def send_request( msg : DNS::Message )
		raise "TODO: implement"
	end
	def get_response() : DNS::Message
		raise "TODO: implement"
	end
end
