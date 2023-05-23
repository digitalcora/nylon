/// Represents an error code returned from the operating system's socket API.
///
/// Since the platform can technically return any error code from any socket
/// operation, every operation must include all of these errors in its error
/// type. Exhaustively matching on these is _not_ recommended; instead, start
/// with a fallback match that assumes the error is unrecoverable (e.g. log it
/// and `panic`), then add cases for specific errors you want to try to recover
/// from.
///
/// Corresponds to the [`inet:posix`][inet-posix] type in Erlang. See also the
/// [descriptions] of the error codes.
///
/// [inet-posix]: https://www.erlang.org/doc/man/inet.html#type-posix
/// [descriptions]: https://www.erlang.org/doc/man/inet.html#posix-error-codes
pub type Error {
  // `inet:posix`
  Eaddrinuse
  Eaddrnotavail
  Eafnosupport
  Ealready
  Econnaborted
  Econnrefused
  Econnreset
  Edestaddrreq
  Ehostdown
  Ehostunreach
  Einprogress
  Eisconn
  Emsgsize
  Enetdown
  Enetunreach
  Enopkg
  Enoprotoopt
  Enotconn
  Enotsock
  Enotty
  Eproto
  Eprotonosupport
  Eprototype
  Esocktnosupport
  Etimedout
  Ewouldblock
  Exbadport
  Exbadseq

  // `file:posix`
  Eacces
  Eagain
  Ebadf
  Ebadmsg
  Ebusy
  Edeadlk
  Edeadlock
  Edquot
  Eexist
  Efault
  Efbig
  Eftype
  Eintr
  Einval
  Eio
  Eisdir
  Eloop
  Emfile
  Emlink
  Emultihop
  Enametoolong
  Enfile
  Enobufs
  Enodev
  Enolck
  Enolink
  Enoent
  Enomem
  Enospc
  Enosr
  Enostr
  Enosys
  Enotblk
  Enotdir
  Enotsup
  Enxio
  Eopnotsupp
  Eoverflow
  Eperm
  Epipe
  Erange
  Erofs
  Espipe
  Esrch
  Estale
  Etxtbsy
  Exdev
}
