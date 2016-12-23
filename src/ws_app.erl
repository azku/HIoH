-module(ws_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).
-export([config/1, data_directory/0]).

-define(APP, ws).
-define(N_ENTRIES, 15000).

start(_Type, _Args) ->
    set_config(topics, ws_topic:encode_topics(config(topics))),
    Routes = [{'_', 
               [{"/ws/[topic/:time_lapse/:topic]", ws_handler, #{}},
                {"/static/[...]", cowboy_static, {priv_dir, ws, "static/"}},
                {"/[topic/:time_lapse/:topic]", ws_html_generation, []}
               ]}],
    Dispatch = cowboy_router:compile(Routes),
    {ok, _} = cowboy:start_clear(haws_http_server, 100, [{port, config(http_port)}],
        			 #{env=> #{dispatch=> Dispatch}}),
    ws_sup:start_link().

stop(_State) ->
	ok.


config(Key) when is_atom(Key)->
    case application:get_env(?APP, Key) of
        undefined when Key==number_of_entries -> ?N_ENTRIES;
        undefined -> erlang:error({missing_config_pair, Key});
        {ok, Val} -> Val
    end.

set_config(Key, Value) when is_atom(Key)->
    application:set_env(?APP, Key, Value).

data_directory()->
    Home = os:getenv("HOME"),
    filename:join([Home, ".ws"]).