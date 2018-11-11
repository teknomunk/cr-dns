class DNS::Resolver
end

class DNS::IterativeResolver < DNS::Resolver
	property cache : DNS::Cache?

	property root_hints = [] of DNS::RR

	def create_resolver_from_a?( rr : DNS::RR::A )
		channel = DNS::Resolver::TCPChannel.new( rr.ip_address, 53 )
		DNS::Resolver.new(channel)
	end
	def create_resolver_from_ns?( rr : DNS::RR::NS )
		#res = resolve( msg=DNS::Message.simple_query("AAAA", rr.name_server )
		res = resolve( msg=DNS::Message.simple_query("A", rr.name_server ) )

		return nil if res.answers.size == 0
		if (rr=res.anwsers[0]).is_a?(DNS::RR::A)
			return create_resolver_from_a(rr)
		else
			return nil
		end
	end

	def resolve( msg : DNS::Message ) : DNS::Message
		# Attempt to use the cache directly
		return msg if !(cache=@cache).nil? && cache.find(msg)

		# If not in the cache, start recursing
		ch = Channel(DNS::Message).new
		spawn do
			ch.send(msg)
		end
		return ch.receive
		#return msg
	end
end
