class DNS::Server::TCPListener < DNS::Server::Listener
	@socket : TCPSocket

	def initialize( addr : String, port : Number )
		@socket = TCPServer.new(addr,port)
	end

	def get_request() : Request?
		if !(s=@socket.accept?).nil?
			size = s.read_network_short.to_i32
			buffer = Bytes.new(size,0)
			count = s.read(buffer)
			raise "Protocol error: expecting #{size} bytes, got #{count}" if count != size

			req = Request.new()
			req.message = Message.decode(buffer)
			req.socket = s
			return req
		end
		return nil
	end
	def send_response( req : Request )
		if !(sock=req.socket).nil?
			data = req.message.encode()
			sock.write_network_short( data.size )
			sock.write(data)
			sock.close()
		end
	end
end # end TCPListener < Listener
