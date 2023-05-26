-module(ip_ffi).
-export([address_parse/1, address_to_string/1, resolve_address/1, resolve_name/2]).

-include("posix_ffi.hrl").
-include_lib("kernel/include/inet.hrl").

-define(is_family(Family), Family =:= inet orelse Family =:= inet6).

address_parse(Binary) ->
    case inet:parse_strict_address(to_charlist(Binary)) of
        {ok, Address} -> {ok, wrap(Address)};
        {error, einval} -> {error, nil}
    end.

address_to_string({Family, Address}) when ?is_family(Family) ->
    case inet:ntoa(Address) of
        Chars when is_list(Chars) -> to_binary(Chars)
    end.

resolve_address({Family, Address}) when ?is_family(Family) ->
    case inet:gethostbyaddr(Address) of
        {ok, #hostent{h_name = Name}} -> {ok, to_binary(Name)};
        {error, nxdomain} -> {error, not_found};
        {error, Error} when ?is_posix_error(Error) -> {error, {posix, Error}}
    end.

resolve_name(Name, Family) ->
    case Family of
        v4 -> do_resolve_name(Name, inet);
        v6 -> do_resolve_name(Name, inet6)
    end.

do_resolve_name(Name, Family) ->
    case inet:gethostbyname(to_charlist(Name), Family) of
        {ok, #hostent{h_name = CanonicalName, h_aliases = Aliases, h_addr_list = Addresses}} ->
            Names = {to_binary(CanonicalName), [to_binary(A) || A <- Aliases]},
            [FirstAddr | RestAddrs] = [wrap(A) || A <- Addresses],
            {ok, {host, Names, {FirstAddr, RestAddrs}}};
        {error, nxdomain} ->
            {error, not_found};
        {error, Error} when ?is_posix_error(Error) -> {error, {posix, Error}}
    end.

to_binary(Chars) when is_list(Chars) -> unicode:characters_to_binary(Chars).
to_charlist(Bin) when is_binary(Bin) -> unicode:characters_to_list(Bin).

wrap(Address) ->
    case Address of
        {_, _, _, _} = V4 -> {inet, V4};
        {_, _, _, _, _, _, _, _} = V6 -> {inet6, V6}
    end.
