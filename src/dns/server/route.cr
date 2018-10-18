class DNS::Server::Route
	@domain : String
	@type : RR::Type
	@cls : RR::Cls
	@handler : Request,RR -> Bool

	def initialize( @domain, @type, @cls, &handler : Request,RR->_ )
		@handler = ->( req : Request, q : RR ) do
			begin
				handler.call(req,q)
			rescue
				req.message.response_code = Message::ResponseCode::ServerFailure
				false
			end
			true
		end
	end
	def try_dispatch( req : Request, q : RR )
			return false if q.type != RR::Type::ANY && @type != RR::Type::ANY && q.type != @type
			return false if (idx=q.name.index(@domain)).nil?
			return false if idx != q.name.size - @domain.size
			return false if q.cls != @cls

			@handler.call(req,q)
			return false
	end
end
