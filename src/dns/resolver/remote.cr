
class DNS::Resolver::Remote < DNS::Resolver
	@channel : DNS::Server::ChannelListener|DNS::Resolver::Channel
	@pending_responses = {} of UInt16 => ::Channel(DNS::Message)?
	property cache : DNS::Cache?

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
	def resolve( msg : DNS::Message, cache_only = false ) : DNS::Message
		raise "Error" if msg.nil?

		# If there is a cache and it matches the request, return that result
		return msg if !(cache=@cache).nil? && cache.find(msg)

		# Force server error if set to only resolve from cache
		if cache_only
			msg.response_code = DNS::Message::ResponseCode::ServerFailure
			return msg
		end

		# Generate a unique id for this message
		msg.id = rand(2**16).to_u16
		while @pending_responses.has_key?(msg.id)
			msg.id = rand(2**16).to_u16
		end

		# Setup a results channel and send the request to the DNS server
		channel = @pending_responses[msg.id] = ::Channel(DNS::Message).new
		@channel.send_request( msg )
		res = channel.receive()
		@pending_responses[msg.id] = nil

		# Add responses to the cache if one exists
		cache.insert(res) if !(cache=@cache).nil?
	
		return res
	end
end

