-module(socket_ffi).
-export([
    accept/2,
    accept_forever/1,
    accept_nowait/1,
    address/1,
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
    sockaddr_in/2,
    sockaddr_un/1,
    transfer/2
]).

-include("posix_ffi.hrl").

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

address(Socket) ->
    case socket:sockname(Socket) of
        {ok, Address} -> {ok, Address};
        {error, Error} -> {error, posix_or_closed(Error)}
    end.

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
        {error, Error} -> {error, posix_or_listen_error(Error)}
    end.

listen(Socket, Backlog) ->
    case socket:listen(Socket, Backlog) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_listen_error(Error)}
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

sockaddr_in({Family, Address}, {port, Port}) when Family =:= inet orelse Family =:= inet6 ->
    #{family => Family, addr => Address, port => Port}.

sockaddr_un(Path) ->
    #{family => local, path => Path}.

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

posix_or_listen_error(Error) ->
    case Error of
        closed -> closed;
        not_bound -> not_bound;
        E when ?is_posix_error(E) -> {posix, E}
    end.
