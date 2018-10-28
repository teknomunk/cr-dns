class DNS::Resolver
end

require "./resolver/*"

class DNS::Resolver
	@channel : DNS::Server::ChannelListener|DNS::Resolver::Channel
	@pending_responses = {} of UInt16 => ::Channel(DNS::Message)?
	def initialize( channel )
		@channel = channel
		spawn do
			loop do
				msg = @channel.get_response()
				if !(c=@pending_responses[msg.id]).nil?
					c.send(msg)
				end
			end
		end
	end
	def resolve( msg : DNS::Message ) : DNS::Message
		raise "Error" if msg.nil?

		msg.id = rand(2**16).to_u16
		while @pending_responses.has_key?(msg.id)
			msg.id = rand(2**16).to_u16
		end

		channel = @pending_responses[msg.id] = ::Channel(DNS::Message).new
		@channel.send_request( msg )
		res = channel.receive()
		@pending_responses[msg.id] = nil
	
		return res
	end
end

