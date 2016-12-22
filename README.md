# HIoH (Home IoT Hub)

HIoH is a Web accesible Hub for interacting with IoT device data and programmed in Erlang.


## Installation

 * Get the project
   git clone https://github.com/azku/HIoH
   cd HIoH
 * Modify the config/sys.config file to tell the system how to connect to MQTT broker and wich port to use for the web server:
```erlang
[
 {sasl,[{errlog_type, error}]},
 {ws, [{topics, [[{topic,<<"/topic/to/subscribe2">>},
                  {fa,<<"fa-thermometer-quarter">>},
                  {name,<<"Livingroom Temperature">>},
                  {unit,<<"C">>}],
                 [{topic, <<"/topic/to/subscribe2">>}, 
                  {fa, <<"fa-umbrella">>}, 
                  {name, <<"Livingroom humidity">>}, {unit, <<37>>}]
                  ]},
       {http_port, 4002},
       {mqtt_host, "localhost"},
       {mqtt_client_id, <<"ws_mqtt_subscriber_client">>},
       {mqtt_username, <<"mqtt_username">>},
       {mqtt_password, <<"mqtt_password">>},
       {mqtt_logger_level, info}
      ]}
].

```
 * Run it

```
make run

```

## Goal

The main objective is to have a hub completely independent of all the devices in which you can monitor it all.
This indepence is bought at the expense of having a reliable protocol as a depencency. The MQTT protocol is believed to
be an adecuate fit for IoT and thus it's the one this project relies upon.

So it is a prerequisite to have a MQTT broker feeding data to HIoH.


 
