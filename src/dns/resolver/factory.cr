abstract class DNS::Resolver::Factory
	abstract def create_resolver_from_a?( rr : DNS::RR::A ) : DNS::Resolver?
	abstract def create_resolver_from_aaaa?( rr : DNS::RR::AAAA ) : DNS::Resolver?
end
