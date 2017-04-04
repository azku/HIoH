-module(ws_feed_memory_acc).
-behaviour(gen_event).
 
-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
terminate/2]).
 

init(Map) ->
    {ok, Map}.

handle_event({publish, Topic = <<"/HIoH/image", _/binary>>, Data}, State)->
    keep_event_in_memory(ws_app:config(number_of_entries_img), Topic, Data, State);
handle_event({publish, Topic, Data}, State)->
    keep_event_in_memory(ws_app:config(number_of_entries_measure), Topic, Data, State);
handle_event(_Event, State) ->
    {ok, State}.
 
handle_call({topic, Topic}, State)->
    case State of
	#{Topic:={_Length, L}} -> {ok, L, State};
	_ -> {ok, State}
    end;
handle_call(_, State) ->
    {ok, ok, State}.
 
handle_info({reply_current_values, Pid}, State)->
    lists:foreach(fun({Topic, {_, [{Time , Data} | _]}})->
			  Pid ! {publish, Topic, Time, Data};
		     (_)->  nothing
		  end,maps:to_list(State)),
    {ok,  State};
handle_info({{topic, Topic}, {last_minutes, X}, {pid, Pid}}, State) when is_binary(X)->
    handle_info({{topic, Topic}, 
                 {last_minutes, list_to_integer(binary_to_list(X))}, 
                 {pid, Pid}}, State);
handle_info({{topic, Topic}, {last_minutes, X}, {pid, Pid}}, State) when is_integer(X)->
    Time = erlang:system_time(1) - (60 * X),
    TopicBase58 = base58:encode(Topic),
    case State of
	#{Topic:={_Length, L}} -> 
	    L2 = lists:takewhile(fun({T, _}) when T >= Time->
					 true;
				    (_) -> false
				 end, L),
	    L3 = lists:foldl(fun({T, V}, BAcc) ->
				     BEpoc = list_to_binary(integer_to_list(T)),
				     <<TopicBase58/binary, " ", BEpoc/binary, " ",V/binary, "\n", BAcc/binary>>
			   end, <<"">>, L2),
	    Pid ! {accumulated, L3},
	    {ok, State};
	_ -> {ok, State}
    end;
handle_info({{topic, Topic}, {skip_events, X}, {pid, Pid}}, State) when is_binary(X)->
    handle_info({{topic, Topic}, 
                 {skip_events, list_to_integer(binary_to_list(X))}, 
                 {pid, Pid}}, State);
handle_info({{topic, Topic}, {skip_events, X}, {pid, Pid}}, State) when is_integer(X)->
    Nth = X +1,
    case State of
        #{Topic := {Length, L}} when Nth=<Length , Nth>0-> 
            {T, D} = lists:nth(Nth, L),
            Pid ! {skip_events, {list_to_binary(integer_to_list(T)), D}},
            {ok, State};
        _ -> {ok, State}
    end;
handle_info(_Msg, State) ->
    {ok, State}.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
 
terminate(_Reason, _State) ->
    ok.


keep_event_in_memory(LengthMax, Topic, Data, State)->
    Time = erlang:system_time(1),
    case State of
	#{Topic:={Length, L}} when Length >= LengthMax-> 
	    [_ | L2] = lists:reverse(L),
	    {ok, State#{Topic=> {Length, [{Time,Data} | lists:reverse(L2)]}}};
	#{Topic:={Length, L}}->
	    {ok, State#{Topic=>{Length + 1, [{Time, Data} | L]}}};
	_->
	    {ok, State#{Topic=>{1, [{Time, Data}]}}}
    end.
    

    
