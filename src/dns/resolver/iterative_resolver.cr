class DNS::Resolver
end

class DNS::Resolver::Iterative < DNS::Resolver
	property cache : DNS::Cache?
	property factory : DNS::Resolver::Factory = DNS::Resolver::NetworkFactory.new

	property root_ns : Array(DNS::RR::NS) = [] of DNS::RR::NS
	property hint_zone = DNS::Zone.new()

	def hint( rr = DNS::RR )
		if rr.is_a?(DNS::RR::NS)
			@root_ns.push(rr)
		end

		@hint_zone.records.push(rr)
	end

	def create_resolver_from_ns?( ns : DNS::RR::NS )
		puts "create_resolver_from_ns?( #{ns.inspect} )"
		res = resolve_local( msg=DNS::Message.simple_query("AAAA", ns.name_server ) )
		#puts "create_resolver_from_ns? -> res:\n#{res.inspect}"

		if !res.nil? && res.answers.size > 0
			if (rr=res.answers[0]).is_a?(DNS::RR::AAAA)
				return @factory.create_resolver_from_aaaa?(rr)
			end
		end

		res = resolve_local( msg=DNS::Message.simple_query("A", ns.name_server ) )

		return nil if res.nil? || res.answers.size == 0

		if (rr=res.answers[0]).is_a?(DNS::RR::A)
			puts "Try to create resolver..."
			return @factory.create_resolver_from_a?(rr)
		else
			return nil
		end
	end

	def resolve_local( msg : DNS::Message ) : DNS::Message?
		puts "resolve_local:"
		puts msg.inspect

		puts "@hint_zone:"
		puts @hint_zone.inspect

		# Attempt to use the cache directly
		return msg if !(cache=@cache).nil? && cache.find(msg)

		# Attempt to return from the hint zone
		if @hint_zone.try_dispatch( msg, msg.questions[0] )
			puts "Using hint zone"
			return msg 
		end

		return nil
	end

	def resolve( msg : DNS::Message  ) : DNS::Message?

		if !(res=resolve_local(msg)).nil?
			return res
		end

		# Will lock up if there are no root hints
		raise "No root hints" if @root_ns.size == 0

		# If not in the cache, start recursing
		ch = ::Channel(DNS::Message?).new
		spawn do
			# Select a random root hit to start resolving
			last_ns = nil
			curr_ns : DNS::RR::NS = @root_ns[ rand(@root_ns.size) ]

			while true
				if curr_ns == last_ns
					ch.send(nil)
					break
				end
				last_ns = curr_ns
				puts "Current NS: #{curr_ns.inspect}"

				# Try to create a resolver from the current nameserver
				if (resolv=create_resolver_from_ns?( curr_ns )).nil?
					puts "b"
					puts "Unable to create resolver from ns #{curr_ns.inspect}"
					msg.response_code = DNS::Message::ResponseCode::ServerFailure
					ch.send(msg)
					break
				else
					puts "c"

					res2 = resolv.resolve(msg)
					puts "d"
					if !res2.nil?
						puts "res=#{res.inspect}"
					end
					if res2.nil?
						# Add response to cache
						if !res2.nil? !(c=@cache).nil?
							c.insert(res2)
						end

						if res2.answers.size > 0
							puts "e"
							# We have our answer
							ch.send(res2)
							break
						else
							puts "d"
							ns_set = [] of DNS::RR::NS
							res2.authority.each {|rr| 
								if rr.is_a?(DNS::RR::NS)
									ns_set.push(rr)
								end
							}
							curr_ns = ns_set[ rand(ns_set.size) ]
						end
					else
						ch.send(nil)
					end
				end
				
				sleep 0.1
			end
			puts "end"
		end
		return ch.receive_with_timeout(30)
	end
end
