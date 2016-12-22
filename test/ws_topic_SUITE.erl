-module(ws_topic_SUITE).
-compile(export_all).
-include_lib("common_test/include/ct.hrl").

all()->
    [fetch_topic_test, encode_topics_test].

encode_topics_test(_Config)->
    L0 = l1(),
    L = ws_topic:encode_topics(L0),
    L0 = lists:map(fun(E)->
                             proplists:delete(topic_base58, E)
                     end, L).

fetch_topic_test(_Config)->
    L = ws_topic:encode_topics(l1()),
    ws_topic:fetch_topic(<<"VHHo6b26M6fr9ugjhanSW4x1E8EzcUoMZmfKvk">>, L).



l1()->
    [[{topic, <<"/haws/livingroom/temperature">>}, {fa, <<"fa-thermometer-quarter">>}, 
      {name, <<"Livingroom Temperature">>}, {unit, <<"C">>}],
     [{topic, <<"/haws/livingroom/humidity">>}, {fa, <<"fa-umbrella">>}, 
      {name, <<"Livingroom humidity">>}, {unit, <<37>>}],
     [{topic, <<"/haws/all/power">>}, {fa, <<"fa-envira">>}, 
      {name, <<"Power consumption">>}, {unit, <<"Wh">>}]].
