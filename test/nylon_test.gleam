import gleam/function
import gleam/erlang/process
import gleeunit
import gleeunit/should
import nylon/ip
import nylon/ip/resolve.{Host}
import nylon/socket
import nylon/socket/async
import nylon/socket/open
import nylon/socket/timeout

pub fn main() {
  gleeunit.main()
}

pub fn ip_test() {
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

pub fn async_test() {
  let assert Ok(socket) = socket.open(open.Inet, open.Stream, open.Default, [])
  let assert Ok(Nil) = socket.listen(socket)
  let assert Ok(address) = socket.address(socket)

  let assert Error(timeout.Timeout) = socket.accept_until(socket, 0)

  let assert async.Select(async.SelectInfo(_tag, handle), Nil) =
    socket.accept_async(socket)

  process.start(
    fn() {
      let assert Ok(client_socket) =
        socket.open(open.Inet, open.Stream, open.Default, [])
      let assert Ok(_conn) = socket.connect(client_socket, address)
      process.sleep_forever()
    },
    linked: True,
  )

  let assert socket.Select(got_socket, got_handle) =
    process.new_selector()
    |> socket.selecting_async(function.identity)
    |> process.select_forever()

  should.equal(socket, got_socket)
  should.equal(handle, got_handle)

  let assert Ok(_conn) = socket.accept_until(socket, 0)
}
