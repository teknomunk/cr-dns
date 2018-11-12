class Mock::NetworkFactory < DNS::Resolver::Factory
	property servers = {} of String => DNS::Server

	{% for i in %w(A AAAA) %}
	def create_resolver_from_{{i.downcase.id}}?( rr : DNS::RR::{{i.id}} ) : DNS::Resolver?
		raise "This should not be called"
		if servers.has_key?(index="{{i.id}} #{rr.ip_address}")
			return DNS::Resolver::Remote.new( servers[index].channel_listener )
		else
			return nil
		end
	end
	{% end %}
end
