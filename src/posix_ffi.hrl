-define(is_posix_error(Error),
    Error =:= eaddrinuse orelse
        Error =:= eaddrnotavail orelse
        Error =:= eafnosupport orelse
        Error =:= ealready orelse
        Error =:= econnaborted orelse
        Error =:= econnrefused orelse
        Error =:= econnreset orelse
        Error =:= edestaddrreq orelse
        Error =:= ehostdown orelse
        Error =:= ehostunreach orelse
        Error =:= einprogress orelse
        Error =:= eisconn orelse
        Error =:= emsgsize orelse
        Error =:= enetdown orelse
        Error =:= enetunreach orelse
        Error =:= enopkg orelse
        Error =:= enoprotoopt orelse
        Error =:= enotconn orelse
        Error =:= enotsock orelse
        Error =:= enotty orelse
        Error =:= eproto orelse
        Error =:= eprotonosupport orelse
        Error =:= eprototype orelse
        Error =:= esocktnosupport orelse
        Error =:= etimedout orelse
        Error =:= ewouldblock orelse
        Error =:= exbadport orelse
        Error =:= exbadseq orelse
        Error =:= eacces orelse
        Error =:= eagain orelse
        Error =:= ebadf orelse
        Error =:= ebadmsg orelse
        Error =:= ebusy orelse
        Error =:= edeadlk orelse
        Error =:= edeadlock orelse
        Error =:= edquot orelse
        Error =:= eexist orelse
        Error =:= efault orelse
        Error =:= efbig orelse
        Error =:= eftype orelse
        Error =:= eintr orelse
        Error =:= einval orelse
        Error =:= eio orelse
        Error =:= eisdir orelse
        Error =:= eloop orelse
        Error =:= emfile orelse
        Error =:= emlink orelse
        Error =:= emultihop orelse
        Error =:= enametoolong orelse
        Error =:= enfile orelse
        Error =:= enobufs orelse
        Error =:= enodev orelse
        Error =:= enolck orelse
        Error =:= enolink orelse
        Error =:= enoent orelse
        Error =:= enomem orelse
        Error =:= enospc orelse
        Error =:= enosr orelse
        Error =:= enostr orelse
        Error =:= enosys orelse
        Error =:= enotblk orelse
        Error =:= enotdir orelse
        Error =:= enotsup orelse
        Error =:= enxio orelse
        Error =:= eopnotsupp orelse
        Error =:= eoverflow orelse
        Error =:= eperm orelse
        Error =:= epipe orelse
        Error =:= erange orelse
        Error =:= erofs orelse
        Error =:= espipe orelse
        Error =:= esrch orelse
        Error =:= estale orelse
        Error =:= etxtbsy orelse
        Error =:= exdev
).
