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
    connect_finish/1,
    connect_nowait/2,
    decode_accept_result/1,
    decode_connect_result/1,
    decode_recv_result/1,
    decode_send_result/1,
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
    transfer/2,
    translate_async_message/3
]).

-include("posix_ffi.hrl").

-define(is_connect_error(Error),
    Error =:= already orelse Error =:= closed orelse Error =:= not_bound orelse Error =:= timeout
).

accept(ListenSocket, Timeout) ->
    translate_accept_result(socket:accept(ListenSocket, Timeout), assert).

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
    translate_connect_result(socket:connect(Socket, Address, Timeout), assert).

connect_finish(Socket) ->
    case socket:connect(Socket) of
        ok -> {ok, nil};
        {error, Error} -> {error, posix_or_closed(Error)}
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
    translate_recv_result(socket:recv(Socket, Length, Flags, Timeout), assert).

recv_forever(Socket, Length, Flags) ->
    recv(Socket, Length, Flags, infinity).

recv_nowait(Socket, Length, Flags) ->
    recv(Socket, Length, Flags, nowait).

send(Socket, Data, {Type, Arg3}, Timeout) when Type =:= normal orelse Type =:= continue ->
    translate_send_result(socket:send(Socket, Data, Arg3, Timeout), assert).

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

translate_async_message(Socket, Type, Data) ->
    case Type of
        abort ->
            {Handle, Error} = Data,
            Reason =
                case Error of
                    closed -> closed;
                    Other -> {unknown, Other}
                end,
            {abort, Socket, Handle, Reason};
        select ->
            {select, Socket, Data};
        completion ->
            {Handle, Result} = Data,
            {completion, Socket, Handle, Result}
    end.

decode_accept_result(Result) -> translate_accept_result(Result, decode).
decode_connect_result(Result) -> translate_connect_result(Result, decode).
decode_recv_result(Result) -> translate_recv_result(Result, decode).
decode_send_result(Result) -> translate_send_result(Result, decode).

translate_accept_result(Result, How) ->
    case Result of
        {ok, {'$socket', _} = Socket} -> {ok, Socket};
        {select, {select_info, _, _} = Info} -> {select, Info, nil};
        {completion, {completion_info, _, _} = Info} -> {completion, Info};
        {error, Error} when Error =:= closed orelse Error =:= timeout -> {error, Error};
        {error, Error} when ?is_posix_error(Error) -> {error, {posix, Error}};
        Other when How =:= assert -> error({unexpected_result, accept, Other});
        Other when How =:= decode -> decode_error(<<"AcceptResult">>, Other)
    end.

translate_connect_result(Result, How) ->
    case Result of
        ok -> {ok, nil};
        {select, {select_info, _, _} = Info} -> {select, Info, nil};
        {completion, {completion_info, _, _} = Info} -> {completion, Info};
        {error, Error} when ?is_connect_error(Error) -> {error, Error};
        {error, Error} when ?is_posix_error(Error) -> {error, {posix, Error}};
        Other when How =:= assert -> error({unexpected_result, connect, Other});
        Other when How =:= decode -> decode_error(<<"ConnectResult">>, Other)
    end.

translate_recv_result(Result, How) ->
    case Result of
        {ok, Data} when is_binary(Data) ->
            {ok, Data};
        {select, {select_info, _, _} = Info} ->
            {select, Info, none};
        {select, {{select_info, _, _} = Info, Data}} when is_binary(Data) ->
            {select, Info, {some, Data}};
        {completion, {completion_info, _, _} = Info} ->
            {completion, Info};
        {error, {Error, Data}} when Error =:= closed orelse Error =:= timeout, is_binary(Data) ->
            {error, {Error, {some, Data}}};
        {error, {Error, Data}} when ?is_posix_error(Error), is_binary(Data) ->
            {error, {{posix, Error}, {some, Data}}};
        {error, Error} when Error =:= closed orelse Error =:= timeout ->
            {error, {Error, none}};
        {error, Error} when ?is_posix_error(Error) ->
            {error, {{posix, Error}, none}};
        Other when How =:= assert -> error({unexpected_result, recv, Other});
        Other when How =:= decode -> decode_error(<<"RecvResult">>, Other)
    end.

translate_send_result(Result, How) ->
    case Result of
        ok ->
            {ok, none};
        {ok, Rest} when is_binary(Rest) ->
            {ok, {some, Rest}};
        {select, {select_info, _, _} = Info} ->
            {select, Info, none};
        {select, {{select_info, _, _} = Info, Rest}} when is_binary(Rest) ->
            {select, Info, {some, Rest}};
        {completion, {completion_info, _, _} = Info} ->
            {completion, Info};
        {error, Error} when Error =:= closed orelse Error =:= timeout ->
            {error, Error};
        {error, Error} when ?is_posix_error(Error) ->
            {error, {posix, Error}};
        Other when How =:= assert -> error({unexpected_result, send, Other});
        Other when How =:= decode -> decode_error(<<"SendResult">>, Other)
    end.

decode_error(Expected, Got) ->
    {error, [
        {decode_error, Expected,
            unicode:characters_to_binary(lists:flatten(io_lib:format("~tw", [Got]))), []}
    ]}.

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

posix_or_listen_error(Error) ->
    case Error of
        closed -> closed;
        not_bound -> not_bound;
        E when ?is_posix_error(E) -> {posix, E}
    end.
