import gleeunit
import gleeunit/should
import nylon/ip
import nylon/ip/resolve.{Host}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  "127.0.0.1"
  |> ip.parse()
  |> should.be_ok()
  |> ip.to_string()
  |> should.equal("127.0.0.1")

  "localhost"
  |> resolve.name(ip.V4)
  |> should.be_ok()
  |> should.equal(Host(
    names: #("localhost", []),
    addresses: #(ip.loopback_v4, []),
  ))

  ip.loopback_v4
  |> resolve.address()
  |> should.be_ok()
  |> should.equal("localhost")
}
