-module(ws_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).
-export([config/1, data_directory/0]).

-define(APP, ws).
-define(N_ENTRIES_MEASURE, 15000).
-define(N_ENTRIES_IMG, 5).

start(_Type, _Args) ->
    set_config(topics, ws_topic:encode_topics(config(topics))),
    Routes = [{'_', 
               [{"/ws/image/:skip_event/:topic", ws_handler, #{}},
                {"/ws/[topic/:time_lapse/:topic]", ws_handler, #{}},
                {"/static/[...]", cowboy_static, {priv_dir, ws, "static/"}},
                {"/[topic/:time_lapse/:topic]", ws_html_generation, []}
               ]}],
    Dispatch = cowboy_router:compile(Routes),
    %% TODO: Add https support in order to use HTTP2
    %% {ok, _} = cowboy:start_tls(https, 100, [
    %%                                         {port, config(http_port)},
    %%                                         {cacertfile, "ca.cert.pem"},
    %%                                         {certfile,  "localhost.cert.pem"},
    %%                                         {keyfile,  "localhost.key.pem"}
    %%                                        ], #{env => #{dispatch => Dispatch}}),
    {ok, _} = cowboy:start_clear(haws_http_server, 100, [{port, config(http_port)}],
        			 #{env=> #{dispatch=> Dispatch}}),
    ws_sup:start_link().

stop(_State) ->
	ok.


config(Key) when is_atom(Key)->
    case application:get_env(?APP, Key) of
        undefined when Key==number_of_entries_measure -> ?N_ENTRIES_MEASURE;
        undefined when Key==number_of_entries_img -> ?N_ENTRIES_IMG;
        undefined -> erlang:error({missing_config_pair, Key});
        {ok, Val} -> Val
    end.

set_config(Key, Value) when is_atom(Key)->
    application:set_env(?APP, Key, Value).

data_directory()->
    Home = os:getenv("HOME"),
    filename:join([Home, ".ws"]).
