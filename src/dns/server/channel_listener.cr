class DNS::Server::ChannelListener < DNS::Server::Listener
	@to_server = Channel(Bytes).new
	@from_server = Channel(Bytes).new

	def send_request( msg : DNS::Message )
		@to_server.send(msg.encode)
	end
	def get_request() : Request?
		req = DNS::Server::Request.new()
		req.message = Message.decode(@to_server.receive())
		req
	end

	def send_response( req : Request )
		@from_server.send(req.message.encode())
	end
	def get_response() : DNS::Message
		Message.decode(@from_server.receive())
	end
end

