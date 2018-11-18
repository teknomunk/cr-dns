class Mock::NetworkFactory < DNS::Resolver::Factory
	# Comment this line to make it no longer crash
	property servers = {} of String => DNS::Server

	{% for i in %w(A AAAA) %}
	def create_resolver_from_{{i.downcase.id}}?( rr : DNS::RR::{{i.id}} ) : DNS::Resolver?
		if servers.has_key?(index="{{i.id}} #{rr.ip_address}")
			return DNS::Resolver::Remote.new( servers[index].channel_listener )
		else
			return nil
		end
	end
	{% end %}
end
