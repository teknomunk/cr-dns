class DNS::Resolver
end

class DNS::Resolver::Iterative < DNS::Resolver
	property cache : DNS::Cache?
	property factory : DNS::Resolver::Factory = DNS::Resolver::NetworkFactory.new

	property root_ns : Array(DNS::RR::NS) = [] of DNS::RR::NS
	@hint_zone = DNS::Zone.new()

	def hint( rr = DNS::RR )
		if rr.is_a?(DNS::RR::NS)
			@root_ns.push(rr)
		end

		@hint_zone.records.push(rr)
	end

	def create_resolver_from_ns?( rr : DNS::RR::NS )
		#res = resolve( msg=DNS::Message.simple_query("AAAA", rr.name_server )
		res = resolve( msg=DNS::Message.simple_query("A", rr.name_server ) )

		return nil if res.answers.size == 0
		if (rr=res.answers[0]).is_a?(DNS::RR::A)
			return @factory.create_resolver_from_a?(rr)
		else
			return nil
		end
	end

	def resolve( msg : DNS::Message ) : DNS::Message?
		puts msg.inspect

		# Attempt to use the cache directly
		return msg if !(cache=@cache).nil? && cache.find(msg)

		# Attempt to return from the hint zone
		return msg if @hint_zone.try_dispatch( msg, msg.questions[0] )

		# Will lock up if there are no root hints
		raise "No root hints" if @root_ns.size == 0

		# If not in the cache, start recursing
		ch = ::Channel(DNS::Message).new
		spawn do
			puts "a"
			# Select a random root hit to start resolving
			curr_ns : DNS::RR::NS = @root_ns[ rand(@root_ns.size) ]

			while true
				puts "b"
				# Try to create a resolver from the current nameserver
				if (resolv=create_resolver_from_ns?( curr_ns )).nil?
					msg.response_code = DNS::Message::ResponseCode::ServerFailure
					ch.send(msg)
					break
				else
					puts "c"
					res = resolv.resolve(msg)

					# Add response to cache
					if !(c=@cache).nil?
						c.insert(res) 
					end

					if res.answers.size > 0
						# We have our answer
						ch.send(res)
						break
					else
						ns_set = [] of DNS::RR::NS
						res.authority.each {|rr| 
							if rr.is_a?(DNS::RR::NS)
								ns_set.push(rr)
							end
						}
						curr_ns = ns_set[ rand(ns_set.size) ]
					end
				end
				
				sleep 0.1
			end
		end
		return ch.receive
	end
end
