class DNS::Server::Route
	@domain : String
	@type : RR::Type
	@cls : RR::Cls
	@handler : Request,RR -> Bool

	def initialize( @domain, @type, @cls, &handler : Request,RR->Bool_ )
		@handler = ->( req : Request, q : RR ) do
			begin
				return handler.call(req,q)
			rescue
				req.message.response_code = Message::ResponseCode::ServerFailure
			end
			return false
		end
	end
	def try_dispatch( req : Request, q : RR ) : Bool
			return false if q.type != RR::Type::ANY && @type != RR::Type::ANY && q.type != @type
			return false if (idx=q.name.index(@domain)).nil?
			return false if idx != q.name.size - @domain.size
			return false if q.cls != @cls

			return @handler.call(req,q)
			#return false
	end
end
