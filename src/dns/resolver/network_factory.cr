class DNS::Resolver::NetworkFactory < DNS::Resolver::Factory
	def create_resolver_from_a?( rr : DNS::RR::A ) : DNS::Resover?
		return nil
	end
	def create_resolver_from_aaaa?( rr : DNS::RR::AAAA ) : DNS::Resolver?
		return nil
	end
end
