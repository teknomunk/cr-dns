class DNS::Server::TCPListener < DNS::Server::Listener
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
