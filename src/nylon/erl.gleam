import gleam/dynamic.{Dynamic}
import gleam/erlang/atom.{Atom}

pub fn atom(name: String) -> Atom {
  let assert Ok(atom) = atom.from_string(name)
  atom
}

pub fn kv(key: String, value: a) -> #(Atom, Dynamic) {
  #(atom(key), dynamic.from(value))
}
