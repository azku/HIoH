-module(ws_handler).


-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).
-export([terminate/3]).

init(Req = #{path := <<"/ws/topic/", _/binary>>}, Opts)->
    TopicBase58 = cowboy_req:binding(topic, Req),
    TL = cowboy_req:binding(time_lapse, Req),
    {cowboy_websocket, Req, Opts#{topic=> base58:decode(TopicBase58), time_lapse=>TL}};
init(Req = #{path := <<"/ws/image/", _/binary>>}, Opts)->
    TopicBase58 = cowboy_req:binding(topic, Req),
    SE = cowboy_req:binding(skip_event, Req),
    {cowboy_websocket, Req, Opts#{topic=> base58:decode(TopicBase58), skip_event=>SE}};
init(Req, Opts) ->
    {cowboy_websocket, Req, Opts#{topic=>all}}.

websocket_init(State) ->
    HandlerId = {ws_feed, make_ref()},
    ok = gen_event:add_handler(ws_event_manager, HandlerId, [self()]),
    {ok, State#{event_handler=>HandlerId}}.

websocket_handle({text, <<"init_current_values">>}, State) ->
    ws_event_manager ! {reply_current_values, self()},
    {ok, State};
websocket_handle({text, <<"init_last_day">>}, State=#{topic:=Topic, time_lapse:= TL}) ->
    ws_event_manager ! {{topic, Topic}, {last_minutes, TL}, {pid, self()}},
    {ok, State};
websocket_handle({text, <<"skip_events ", SE/binary>>}, State=#{topic:=Topic}) ->
    ws_event_manager ! {{topic, Topic}, {skip_events, SE}, {pid, self()}},
    {ok, State};
websocket_handle(_Data, State) ->
    {ok, State}.

websocket_info({publish, Topic, Data}, State) ->
    %%Normalise data to include time
    websocket_info({publish, Topic, erlang:system_time(1), Data}, State);
websocket_info({publish, Topic, _Time, Data}, State=#{topic:=Topic}) ->
    TopicBase58 = base58:encode(Topic),
    Time = list_to_binary(integer_to_list(erlang:system_time(1))),
    {reply, {text, <<TopicBase58/binary, " ", Time/binary, " ",Data/binary>>},  State};
websocket_info({publish, Topic = <<"/HIoH/image", _/binary>>, Time0, Data}, State=#{topic:=all}) ->
    TopicBase58 = base58:encode(Topic),
    Time = list_to_binary(integer_to_list(Time0)),
    {reply, [{text, <<TopicBase58/binary, " ", Time/binary, " image" >> }, 
             {binary, Data}],  State};   
websocket_info({publish, Topic, _Time, <<"cmd ", Data/binary>>}, State=#{topic:=all}) ->
    TopicBase58 = base58:encode(Topic),
    Time = list_to_binary(integer_to_list(erlang:system_time(1))),
    CmdExecTime = humanised_interval(erlang:system_time(1), list_to_integer(binary_to_list(Data))),
    {reply, {text, <<TopicBase58/binary, " ", Time/binary, " ",CmdExecTime/binary>>},  State};
websocket_info({publish, <<"/HIoH/image", _/binary>>, _Time, _Image}, State=#{topic:=Topic}) ->
    TopicBase58 = base58:encode(Topic),
    Time = list_to_binary(integer_to_list(erlang:system_time(1))),
    {reply, {text, <<TopicBase58/binary, " ", Time/binary>>}, State};
websocket_info({publish, Topic, _Time, Data}, State=#{topic:=all}) ->
    TopicBase58 = base58:encode(Topic),
    Time = list_to_binary(integer_to_list(erlang:system_time(1))),
    {reply, {text, <<TopicBase58/binary, " ", Time/binary, " ",Data/binary>>},  State};
websocket_info({skip_events, {Time, Data}}, State=#{topic:=Topic}) ->
    TopicBase58 = base58:encode(Topic),
    Reply = [{text, <<TopicBase58/binary, " ", Time/binary, " image" >> }, 
             {binary, Data}],
    {reply, Reply , State};
websocket_info({accumulated,  L}, State) ->
    {reply, {text, L}, State};
websocket_info(_Info, State) ->
    {ok, State}.

terminate(_, _Req, #{event_handler:=EH}) ->
    gen_event:delete_handler(ws_event_manager, EH, leave_feed),
    ok.



humanised_interval(Epoc1, Epoc0) when Epoc1 - Epoc0 < 60->
    <<"Now">>;
humanised_interval(Epoc1, Epoc0) when Epoc1 - Epoc0 < 60 * 60->
    <<"Minutes_ago">>;
humanised_interval(Epoc1, Epoc0) when Epoc1 - Epoc0 < 60 * 60 *24->
    <<"Hours_ago">>;
humanised_interval(_, _) ->
    <<"Days_ago">>.
