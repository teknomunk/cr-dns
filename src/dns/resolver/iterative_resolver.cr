class DNS::Resolver
end

class DNS::Resolver::Iterative < DNS::Resolver
	property cache : DNS::Cache?
	property factory : DNS::Resolver::Factory = DNS::Resolver::NetworkFactory.new

	property root_ns = [] of DNS::RR::NS
	property root_ns_a = [] of DNS::RR::A

	def create_resolver_from_a?( rr : DNS::RR::A )
		channel = DNS::Resolver::TCPChannel.new( rr.ip_address, 53 )
		return DNS::Resolver.new(channel)
	end
	#def create_resolver_from_aaaa?( rr : DNS::RR::AAAA )
	#	# TODO: Implement
	#end

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
			# Select a random root hit to start resolving
			curr_ns = DNS::RR::NS.new
			curr_ns.dname = "."
			curr_ns.name_server = root_hints[ rand(root_hints.size) ]

			while true
				# Try to create a resolver from the current nameserver
				if (resolv=create_resolver_from_ns?( curr_ns )).nil?
					msg.response_code = DNS::Message::ResponseCode::ServerFailure
					ch.send(msg)
					break
				else
					res = resolv.resolve(msg)

					# Add response to cache
					cache.insert(res) if !(cache=@cache).nil?

					if res.answers.size > 0
						# We have our answer
						ch.send(res)
						break
					else
						ns_set = res.authority.select {|rr| rr.is_a?(DNS::RR::NS) }
						curr_ns = ns_set[ rand(ns_set.size) ]
					end
				end
				
				sleep 0.1
			end
		end
		return ch.receive
	end
end
