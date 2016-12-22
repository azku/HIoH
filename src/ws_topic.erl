-module(ws_topic).

-export([encode_topics/1, fetch_topic/2, fetch_topic_key/3]).

fetch_topic(TopicBase58, Lst = [PL | _])->
    fetch_topic(TopicBase58, Lst, proplists:get_value(topic_base58, PL)).
fetch_topic(TopicBase58, [PL | _], TopicBase58) ->
    PL;
fetch_topic(TopicBase58, [_, PL | Rest], _) ->
    fetch_topic(TopicBase58, [PL | Rest],  proplists:get_value(topic_base58, PL)).

fetch_topic_key(Key, TopicBase58, L)->
    proplists:get_value(Key, fetch_topic(TopicBase58, L)).

encode_topics(Lst)->
    lists:map(fun(E)->
                      T = proplists:get_value(topic, E),
                      [{topic_base58, base58:encode(T)} | E]
              end,Lst).
