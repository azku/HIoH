# HIoH (Home IoT Hub)

HIoH is a Web accessible Hub for interacting with IoT device data and programmed in Erlang.

## Prerequisites

Erlang > V17
An MQTT broker receiving sensor raw values


## Installation

Get the project:

```
git clone https://github.com/azku/HIoH
cd HIoH

```
Compile

```
make run

```

Modify the configuration files config/sys.config and config/extra.config file:

config/sys.config
```erlang
[
 {sasl,[{errlog_type, error}]},
 {ws, [
       {http_port, 4002},
       {mqtt_host, "localhost"},
       {mqtt_client_id, <<"ws_mqtt_subscriber_client">>},
       {mqtt_logger_level, info}
      ]}
].

```

config/extra.config

```erlang

[{ws,
[{topics, [[{topic,<<"/topic/to/subscribe2">>},
                  {fa,<<"fa-thermometer-quarter">>},
                  {name,<<"Living-room Temperature">>},
                  {unit,<<"C">>}],
                 [{topic, <<"/topic/to/subscribe2">>}, 
                  {fa, <<"fa-umbrella">>}, 
                  {name, <<"Living-room humidity">>}, {unit, <<37>>}]
                  ]},
 {mqtt_username, <<"haws_user">>},
 {mqtt_password, <<"haws_user">>}]}]
 
```
Notice the MQTT username and password needed to connect to the broker, the http_port in which the web server is going to run and the list of topics to subscribe. HIoH would expect the sensor messages to queue up in these topics.

Also note the use of two different config files. This technique is based on [this inaka article](http://inaka.net/blog/2015/07/14/erlang-config-include/).


Run the OTP application:

```
make run

```

Access the selected port via a modern browser and watch the sensor data as its been received


## Goal

The main objective is to have a hub completely independent of all the devices in which you can monitor it all.
This independence is bought at the expense of having a reliable protocol as a dependency. The MQTT protocol is believed to
be an adequate fit for IoT and thus it's the one this project relies upon.


## Architecture

As a picture is believed to be worth a thousand words...
 
![HIoH architecture image](hioh.png?raw=true)


## License

HIoH source code is [licensed under the MIT](LICENSE.md).


## Copyright

(c) 2016, Asier Azkuenaga Batiz
