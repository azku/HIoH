# HIoH (Home IoT Hub)

HIoH is a Web accessible Hub for interacting with IoT device data and programmed in Erlang.

## Prerequisites

Erlang > V17
An MQTT broker ready to receive raw values on different topics


## Installing

Get the project:

```
git clone https://github.com/azku/HIoH
cd HIoH

```
Compile

```
make

```

## Configuration

We need to configure how to connect to the MQTT broker and which topics are going to be subscribed by HIoH. 
This could achieved by modifying the configuration files config/sys.config and config/extra.config file:

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
[{topics, [[{topic,<<"/HIoH/measure/livingroom/temperature">>},
                {fa,<<"fa-thermometer-quarter">>},
                {name,<<"Livingroom Temperature">>},
                {unit,<<"C">>}],
               [{topic, <<"/HIoH/measure/livingroom/humidity">>}, 
                {fa, <<"fa-umbrella">>}, 
                {name, <<"Livingroom humidity">>}, {unit, <<37>>}],
               [{topic, <<"/HIoH/measure/all/power">>}, {fa, <<"fa-envira">>}, 
                {name, <<"Power consumption">>}, {unit, <<"Wh">>}],
               [{topic, <<"/HIoH/image/outside/camera">>}, {fa, <<"fa-video-camera">>}, 
                {name, <<"Outside Camera">>}, {unit, <<"">>}],
               [{topic, <<"/HIoH/cmd/livingroom/restart_pi">>}, {fa, <<"fa-power-off">>}, 
                {name, <<"Restart RPi">>}, {unit, <<"">>}]]},
 {mqtt_username, <<"haws_user">>},
 {mqtt_password, <<"haws_user">>}]}]
 
```
Notice the MQTT username and password needed to connect to the broker, the http_port in which the web server is going to run and the list of topics to subscribe. HIoH would expect the sensor messages to queue up in these topics.

Also note the use of two different config files. This technique is based on [this inaka article](http://inaka.net/blog/2015/07/14/erlang-config-include/).

### A word on topics
Topics are easy to set up but there is a convention on how to do it:

#### Composition of the name

1. The first part, is the name of the application */HIoH* 

2. Then a value indicating a reception of a */measure* (such as temperature),
   a reception of a */image* blob or a sending of a */cmd* command.

3. Physical location of the sender (in case of measure or image) or receiver (in case of cmd)

4. Type of data (temperature, humidity,...)

#### The Icon

HIoH uses [Font Awesome](http://fontawesome.io/icons/) icons. Each topic it's assigned an icon and is configured by using it's awesome icon's name.

#### Unit

In case of a measure topic, The unit can be specified.

#### Name

The title of the topic. In other words, the displayed name for the topic.




Ones the configuration is finished, run the OTP application:

```
make run

```

Access the selected port via a modern browser and the IoT Hub its up!


## Goal

The main objective is to have a hub completely independent of all the devices, where you can monitor everything and send commands everywhere.
This independence is bought at the expense of having a reliable protocol as a dependency. The MQTT protocol is believed to
be an adequate fit for IoT and thus it's the one this project relies upon.


## Architecture

As a picture is believed to be worth a thousand words...
 
![HIoH architecture image](hioh.png?raw=true)


## License

HIoH source code is [licensed under the MIT](LICENSE.md).


## Copyright

(c) 2016, Asier Azkuenaga Batiz
