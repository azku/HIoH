-module(ws_feed_file_acc).
-behaviour(gen_event).
 
-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
terminate/2]).
 
-define(N_ENTRIES, ws_app:config(number_of_entries)).

init(_ListOfTopic) ->
    %%Ensure file exists
    LstIoDevice = 
        lists:map(fun(E)->
                          TopicBase58 = proplists:get_value(topic_base58, E),
                          Dir = ws_app:data_directory(),
                          {ok, IoDevice} = file:open(filename:join([Dir, TopicBase58]), [read, write, raw, binary]),
                          {TopicBase58, IoDevice}
                  end, ws_app:config(topics)),
    {ok, LstIoDevice}.

handle_event({publish, Topic, Data}, LstIoDevice)->
    %% Cotinuous limited stream
    Time = list_to_binary(integer_to_list(erlang:system_time(1))),
    TopicBase58 = base58:encode(Topic),
    IoDevice = proplists:get_value(TopicBase58, LstIoDevice),
    {ok, _} = file:position(IoDevice, {eof, 0}),
    ok = file:write(IoDevice, <<Time/binary, " ", Data/binary, "\n">>),
    {ok, LstIoDevice};
handle_event(_Event, State) ->
    {ok, State}.
 
handle_call({{topic, Topic = <<"/haws/measure">>}}, LstIoDevice) ->
    Bytes = ?N_ENTRIES * 20,
    TopicBase58 = base58:encode(Topic),
    IoDevice = proplists:get_value(TopicBase58, LstIoDevice),
    RealBytes = case file:position(IoDevice, eof) of
		    {ok, NP} when NP>Bytes-> Bytes;
		    {ok, NP} -> NP
		end,
    {ok,_} = file:position(IoDevice, {eof, -RealBytes }),
    {ok, Data} = file:read(IoDevice, RealBytes),
    LReturn = case binary:split(Data, <<"\n">>, [global, trim]) of
                  [_| Result]-> 
                      lists:reverse(lists:map(fun(E)-> 
                                                      [A, B]= binary:split(E, <<" ">>),
                                                      {list_to_integer(binary_to_list(A)),B}
                                              end, Result));
                  []-> []
              end,
    {ok, LReturn , LstIoDevice};
handle_call({{topic, _Topic }}, LstIoDevice) ->
    {ok, [], LstIoDevice};
handle_call(_, State) ->
    {ok, ok, State}.
 
handle_info(_Msg, State) ->
    {ok, State}.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
 
terminate(_Reason, LstIoDevice) ->
    lists:foreach(fun({_, IoDevice})->
			  file:close(IoDevice)
		  end, LstIoDevice),
    ok.

    

    
