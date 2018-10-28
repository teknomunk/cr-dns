abstract class DNS::Resolver::Channel
	abstract def send_request( msg : DNS::Message )
	abstract def get_response() : DNS::Message
end
