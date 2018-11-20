abstract class DNS::Server::Listener
	property request_channel = Channel(Request).new()
	property response_channel = Channel(Request).new()

	abstract def get_request() : Request?
	abstract def send_response( req : Request )

	def run()
		#puts "Starting listener loop"
		spawn do
			loop {
				begin
					# Get the request
					if !(req=get_request()).nil?
						# Send to the main thread to process
						@request_channel.send(req)
					end
				rescue e
					# Report server error
					puts "Caught error: #{e}"
					if req
						req.message.response_code = Message::ResponseCode::ServerFailure
						send_response(req)
					end
				end
			}
		end
		spawn do
			loop {
				res = monitor "DNS::Server::Listener" { @response_channel.receive }
				send_response(res)
			}
		end
	end
end

