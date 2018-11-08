# dns

Work In Progress - This is not yet a usable library

Features:
 * Basic server and resolver functionality over TCP and UDP (not yet standards compliant)
 * Zone file reader
 * Currently supported Resource Records: A, CNAME, MX, NS, PTR, SOA, and TXT
 * Partially supported Resource Records: AAAA, HINFO, and OPT

Partially implemented:
 * DNS response caching

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  dns:
    github: teknomunk/cr-dns
```

## Usage

### Client
```crystal
require "dns"

resolv = DNS::Resolver.new( DNS::Server::TCPChannel.new( "127.0.0.0", 5353 ) )
resolv.send_request( DNS::Message.simple_query( "A", "example.com." ) )
msg = resolv.get_response()

if msg.answers.size > 0 && (rr=msg.answers[0]).is_a?(DNS::RR::A)
	puts rr.ip_address
end
```

### Server
```crystal
require "dns"

server = DNS::Server.new()
server.listen_udp( "0.0.0.0", 5353 )
server.listen_tcp( "0.0.0.0", 5353 )
server.add_zone( DNS::Zone.new( File.open("test.zone") ) )

server.run()
```

## Contributing

1. Fork it (<https://github.com/teknomunk/cr-dns/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [teknomunk](https://github.com/teknomunk) teknomunk - creator, maintainer
