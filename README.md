# Nylon

<!-- [![Package Version](https://img.shields.io/hexpm/v/nylon)](https://hex.pm/packages/nylon)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/nylon/) -->

Sockets and networking for Gleam on the BEAM.


## Installation

This project is not available on Hex yet, so there is no way to install it.
Which is probably fine, because it's also not ready for use. Check back later?


## Development

This project uses [`asdf`](https://asdf-vm.com/) to manage tool versions in
development.

Due to an [issue] with the Rebar plugin, a standard `asdf install` will fail
with the error _"No version is set for command escript"_. To work around this
you must install Erlang, use `asdf shell` to activate it, then install Rebar.
The script `bin/setup` will attempt to do this for you.

[issue]: https://github.com/Stratus3D/asdf-rebar/issues/10#issuecomment-1004371871
