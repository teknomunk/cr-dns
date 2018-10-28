class DNS::Resolver
end

require "./resolver/*"

class DNS::Resolver
	@channel : DNS::Server::ChannelListener|DNS::Resolver::Channel
	def initialize( channel )
		@channel = channel
	end
	def resolve( msg : DNS::Message? ) : DNS::Message
		raise "Error" if msg.nil?

		@channel.send_request( msg )
		@channel.get_response()
	end
end

