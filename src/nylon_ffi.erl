-module(nylon_ffi).
-export([
    accept/2,
    accept_forever/1,
    accept_nowait/1,
    bind/2,
    cancel/2,
    close/1,
    connect/3,
    connect_forever/2,
    connect_nowait/2,
    listen/1, listen/2,
    open/4,
    recv/4,
    recv_forever/3,
    recv_nowait/3,
    send/4,
    send_forever/3,
    send_nowait/3,
    shutdown/2,
    transfer/2
]).

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

accept(ListenSocket, Timeout) ->
    case socket:accept(ListenSocket, Timeout) of
        {ok, Socket} -> {ok, Socket};
        {select, Info} -> {select, Info, nil};
        {completion, Info} -> {completion, Info};
        {error, Error} -> {error, posix_or_closed_or_timeout(Error)}
    end.

accept_forever(ListenSocket) ->
    accept(ListenSocket, infinity).

accept_nowait(ListenSocket) ->
    accept(ListenSocket, nowait).

bind(Socket, Addr) ->
    case socket:bind(Socket, Addr) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed(Error)}
    end.

cancel(Socket, Info) ->
    case socket:cancel(Socket, Info) of
        ok -> {ok, nil};
        {error, closed} -> {error, closed};
        {error, {invalid, _}} -> {error, invalid}
    end.

close(Socket) ->
    case socket:close(Socket) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed_or_timeout(Error)}
    end.

connect(Socket, Address, Timeout) ->
    case socket:connect(Socket, Address, Timeout) of
        ok -> {ok, nil};
        {select, Info} -> {select, Info, nil};
        {completion, Info} -> {completion, Info};
        {error, Error} -> {error, posix_or_connect_error(Error)}
    end.

connect_forever(Socket, Address) ->
    connect(Socket, Address, infinity).

connect_nowait(Socket, Address) ->
    connect(Socket, Address, nowait).

listen(Socket) ->
    case socket:listen(Socket) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed(Error)}
    end.

listen(Socket, Backlog) ->
    case socket:listen(Socket, Backlog) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed(Error)}
    end.

open(Domain, Type, Protocol, Opts) ->
    case socket:open(Domain, Type, Protocol, maps:from_list(Opts)) of
        {ok, Socket} -> {ok, Socket};
        {error, E} when ?is_posix_error(E) -> {error, E}
    end.

recv(Socket, Length, Flags, Timeout) ->
    case socket:recv(Socket, Length, Flags, Timeout) of
        {ok, Data} -> {ok, Data};
        {select, {Info, Data}} -> {select, Info, {some, Data}};
        {select, Info} -> {select, Info, none};
        {completion, Info} -> {completion, Info};
        {error, {Error, Data}} -> {error, {posix_or_closed_or_timeout(Error), {some, Data}}};
        {error, Error} -> {error, {posix_or_closed_or_timeout(Error), none}}
    end.

recv_forever(Socket, Length, Flags) ->
    recv(Socket, Length, Flags, infinity).

recv_nowait(Socket, Length, Flags) ->
    recv(Socket, Length, Flags, nowait).

send(Socket, Data, {Type, Arg3}, Timeout) when Type =:= normal orelse Type =:= continue ->
    case socket:send(Socket, Data, Arg3, Timeout) of
        ok -> {ok, none};
        {ok, Rest} -> {ok, {some, Rest}};
        {select, {Info, Rest}} -> {select, Info, {some, Rest}};
        {select, Info} -> {select, Info, none};
        {completion, Info} -> {completion, Info};
        {error, Error} -> {error, posix_or_closed_or_timeout(Error)}
    end.

send_forever(Socket, Data, Disposition) ->
    send(Socket, Data, Disposition, infinity).

send_nowait(Socket, Data, Disposition) ->
    send(Socket, Data, Disposition, nowait).

shutdown(Socket, How) ->
    case socket:shutdown(Socket, How) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed(Error)}
    end.

transfer(Socket, Pid) ->
    case socket:setopt(Socket, {otp, controlling_process}, Pid) of
        ok -> {ok, nil};
        {error, closed} -> {error, closed};
        {error, {invalid, not_owner}} -> {error, not_owner}
    end.

posix_or_closed(Error) ->
    case Error of
        closed -> closed;
        E when ?is_posix_error(E) -> {posix, E}
    end.

posix_or_closed_or_timeout(Error) ->
    case Error of
        closed -> closed;
        timeout -> timeout;
        E when ?is_posix_error(E) -> {posix, E}
    end.

posix_or_connect_error(Error) ->
    case Error of
        already -> already;
        closed -> closed;
        not_bound -> not_bound;
        timeout -> timeout;
        E when ?is_posix_error(E) -> {posix, E}
    end.
