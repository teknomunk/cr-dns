class DNS::Resolver::TCPChannel < DNS::Resolver::Channel
	@results = ::Channel(DNS::Message).new

	def initialize( @hostname : String, @port : Int32 )
	end
	def send_request( msg : DNS::Message )
		sock = TCPSocket.new(@hostname,@port)

		data = msg.encode()
		sock.write_network_short( data.size )
		sock.write(data)
		spawn do
			size = sock.read_network_short().to_i32
			buffer = Bytes.new(size,0)
			sock.read(buffer)
			@results.send( DNS::Message.decode(buffer) )
		end
	end
	def get_response() : DNS::Message
		return @results.receive
	end
end
