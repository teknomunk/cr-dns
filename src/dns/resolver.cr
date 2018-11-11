abstract class DNS::Resolver
	abstract def resolve( msg : DNS::Message, cache_only = false ) : DNS::Message
end

require "./resolver/*"
