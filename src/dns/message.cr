class DNS::Message
	enum Type
		Query
		Response
	end
	enum QueryType
		Query
		InverseQuery
		Status
		Notify
		Update
	end
	enum ResponseCode
		NoError
		FormatError
		ServerFailure
		NameError
		NotImplemented
		Refused
		YX_Domain
		YX_RR_Set
		NX_RR_Set
		NotAuth
		NotZone
	end

	property id : UInt16 = 0

	property query : Type = Type::Query
	property query_type : QueryType = QueryType::Query
	property authoritative : Bool = false
	property truncated : Bool = false
	property recursion_desired : Bool = false
	property recursion_available : Bool = false
	property response_code : ResponseCode = ResponseCode::NoError
	property authenticated : Bool = false
	property accept_non_auth : Bool = true

	property questions  : Array(DNS::RR) = [] of DNS::RR
	property answers	: Array(DNS::RR) = [] of DNS::RR
	property authority	: Array(DNS::RR) = [] of DNS::RR
	property additional : Array(DNS::RR) = [] of DNS::RR

	def self.decode( packet : Bytes )
		msg = DNS::Message.new
		msg.id = packet[0].to_u16 << 8 | packet[1]
		msg.query = packet[2] & 0x80 == 0x80 ? Type::Response : Type::Query
		case (packet[2] >> 3 ) & 0x0F
			when 0
				msg.query_type = QueryType::Query
			when 1
				msg.query_type = QueryType::InverseQuery
			when 2
				msg.query_type = QueryType::Status
			when 4
				msg.query_type = QueryType::Notify
			when 5
				msg.query_type = QueryType::Update
		end

		msg.authoritative = !!(packet[2] & 0x04 == 0x04)
		msg.truncated = !!(packet[2] & 0x02 == 0x02)
		msg.recursion_desired = !!(packet[2] & 0x01 == 0x01)
		msg.recursion_available = !!(packet[3] & 0x80 == 0x80)
		msg.authenticated = !!(packet[3] & 0x20 == 0x20)
		msg.accept_non_auth = !!(packet[3] & 0x10 == 0x10)
		case packet[3]&0x0F
			when 0
				msg.response_code = ResponseCode::NoError
			when 1
				msg.response_code = ResponseCode::FormatError
			when 2
				msg.response_code = ResponseCode::ServerFailure
			when 3
				msg.response_code = ResponseCode::NameError
			when 4
				msg.response_code = ResponseCode::NotImplemented
			when 5
				msg.response_code = ResponseCode::Refused
			when 6
				msg.response_code = ResponseCode::YX_Domain
			when 7
				msg.response_code = ResponseCode::YX_RR_Set
			when 8
				msg.response_code = ResponseCode::NX_RR_Set
			when 9
				msg.response_code = ResponseCode::NotAuth
			when 10
				msg.response_code = ResponseCode::NotZone
			else
				msg.response_code = ResponseCode::ServerFailure
		end

		question_count = packet[4].to_u16 << 8 | packet[5]
		answer_record_count = packet[6].to_u16 << 8 | packet[7]
		authority_count = packet[8].to_u16 << 8 | packet[9]
		additional_record_count = packet[10].to_u16 << 8 | packet[11]

		question_count.times {
			
		}
	end
end
