-module(ws_mqtt_subscriber).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([publish/2]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).
-define(MAXLENGTH, 50).


start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

publish(Topic, Msg)->
    gen_server:cast(?MODULE, {publish, Topic, Msg}).

init([]) ->
    {ok, C} = emqttc:start_link([{host, ws_app:config(mqtt_host)}, {client_id, ws_app:config(mqtt_client_id)}, 
                                 {username, ws_app:config(mqtt_username)}, {password, ws_app:config(mqtt_password)}, 
                                 {logger, ws_app:config(mqtt_logger_level)}]),
    lists:foreach(fun(E)->
			  Topic = proplists:get_value(topic, E),
			  emqttc:subscribe(C, Topic, 0)
		  end, ws_app:config(topics)),
    {ok, #{client=>C}}.


handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({publish, Topic, Msg}, State=#{client:=C})->
    emqttc:publish(C, Topic, Msg),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({publish, Topic, Data}, State) ->
    gen_event:notify(ws_event_manager, {publish, Topic, Data}),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
