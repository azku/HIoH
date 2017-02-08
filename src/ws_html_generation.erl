-module(ws_html_generation).

-export([init/2]).
-export([terminate/3]).

init(Req = #{path := <<"/topic/cmd", _/binary>>, method := <<"GET">>}, State)->
    TopicBase58 = cowboy_req:binding(topic, Req),
    _Topic = ws_topic:fetch_topic_key(topic, TopicBase58, ws_app:config(topics)),
    _TL = cowboy_req:binding(time_lapse, Req),
    {ok, Html} = command_confirmation_dtl:render([]),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Html, Req),
    {ok, Req2, State};
init(Req = #{path := <<"/topic/cmd", _/binary>>, method := <<"POST">>}, State)->
    TopicBase58 = cowboy_req:binding(topic, Req),
    Topic = ws_topic:fetch_topic_key(topic, TopicBase58, ws_app:config(topics)),
    BEpoc = list_to_binary(integer_to_list(erlang:system_time(1))),
    ws_mqtt_subscriber:publish(Topic, <<"cmd ", BEpoc/binary>> ),
    Req2 = cowboy_req:reply(302,#{<<"Location">> => <<"../../">>},  Req),
    {ok, Req2, State};
init(Req = #{path := <<"/topic", _/binary>>}, State)->
    TopicBase58 = cowboy_req:binding(topic, Req),
    Topic = ws_topic:fetch_topic_key(topic, TopicBase58, ws_app:config(topics)),
    TL = cowboy_req:binding(time_lapse, Req),
    VData = [{topic_base58, TopicBase58}, {time_lapse, TL}, 
             {topic, Topic}, {humanized_time_lapse, humanize_time_lapse(TL)} ],
    {ok, Html}= topic_dtl:render(append_new_tl(TL, VData)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}, Html, Req),
    {ok, Req2, State};
init(Req,State) ->
    {LSensor, LCmd} = lists:partition(fun(SL)->
                            case binary:match(proplists:get_value(topic, SL), <<"cmd">>) of
                                nomatch -> true;
                                _ -> false                             
                            end
                    end, ws_app:config(topics)),
    L = lists:foldl(fun(E2, [[ E1]|Acc])->
			    [[ E1,  E2] | Acc];
		       (E1, Acc)->
			    [[E1] | Acc]
		    end, [], LSensor),
    L2 = lists:foldl(fun(E2, [[ E1]|Acc])->
			    [[ E1,  E2] | Acc];
		       (E1, Acc)->
			    [[E1] | Acc]
                end, [], LCmd),
    {ok, Resp} = current_values_dtl:render([{topic_list, L}, {command_list, L2}]),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"text/html">>}
			   , Resp, Req),
    {ok, Req2, State}.


terminate(_Reason, _Req, _State) ->
	ok.

append_new_tl(TL, L) when is_binary(TL)->
    append_new_tl(list_to_integer(binary_to_list(TL)), L);
append_new_tl(TL, L) when TL>5->
    [{decreased_time_lapse, TL div 2}, {increased_time_lapse, TL * 2} | L];
append_new_tl(TL, L) ->
    [{increased_time_lapse, TL * 2} | L].

humanize_time_lapse(TL) when is_binary(TL)->
    humanize_time_lapse(list_to_integer(binary_to_list(TL)));
humanize_time_lapse(TL) when TL >60 ->
    BTL = list_to_binary(integer_to_list(TL div 60)),
    <<BTL/binary, " hours">>;
humanize_time_lapse(TL) ->
    BTL = list_to_binary(integer_to_list(TL)),
    <<BTL/binary, " minutes">>.
    
