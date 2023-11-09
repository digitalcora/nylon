# Nylon

<!-- [![Package Version](https://img.shields.io/hexpm/v/nylon)](https://hex.pm/packages/nylon)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/nylon/) -->

Networking for Gleam on the BEAM.


## Installation

This project is not available on Hex yet, so there is no way to install it.
Which is probably fine, because it's also not ready for use. Check back later?


## Development

This project uses [`asdf`](https://asdf-vm.com/) to manage tool versions in
development.

Due to an [issue] with the Rebar plugin, `asdf install` may fail with the error
_"No version is set for command escript"_. To work around this: `asdf install
erlang`, run `asdf shell erlang <VERSION>` for the just-installed version, then
in the same shell, `asdf install rebar`. From here, `asdf install` should work
to install the remaining tool dependencies. (Use `asdf shell erlang --unset` to
undo the effects of the earlier `shell` command.)

[issue]: https://github.com/Stratus3D/asdf-rebar/issues/10#issuecomment-1004371871
