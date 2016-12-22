-module(ws_sup).
-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->    
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    ok= gen_event:add_handler(ws_event_manager, ws_feed_file_acc, []),
    Map = lists:foldl(fun(E, M)->
        		      Topic = proplists:get_value(topic, E),
        		      L2 = gen_event:call(ws_event_manager, ws_feed_file_acc, {{topic, Topic}}),
        		      M#{Topic=>{length(L2), L2}}
        	      end, #{}, ws_app:config(topics)),
    ok= gen_event:add_handler(ws_event_manager, ws_feed_memory_acc, Map),
    {ok, Pid}.

init([]) ->
    EventManager = {ws_event_manager, {gen_event, start_link, [{local, ws_event_manager}]},
		   permanent, 5000, worker, [dynamic]},
    MQTTS = {ws_mqtt_subscriber,{ws_mqtt_subscriber,start_link,[]},
	      permanent,5000,worker,[ws_mqtt_subscriber]},
    Procs = [EventManager, MQTTS],
    {ok, {{one_for_one, 1, 5}, Procs}}.
