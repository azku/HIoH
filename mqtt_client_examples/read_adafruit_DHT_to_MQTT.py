#!/usr/bin/python
# Copyright (c) 2014 Adafruit Industries
# Author: Tony DiCola

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
import sys
import Adafruit_DHT
import paho.mqtt.client as mqtt
import sqlite3

from sqlite3 import Error

sensor = Adafruit_DHT.AM2302
pin = 4

sqlite_file = 'PATH_TO_SQLITE_FILE'
table_name = 'DHT'
sql_create = "CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, temp REAL, hum REAL)" % (table_name)
sql_insert = "insert into %s(temp,hum) values(?,?) " % (table_name)

mqttc = mqtt.Client(None)
mqttc.username_pw_set("MQTT_USER", "MQTT_PASSWORD")



# Try to grab a sensor reading.  Use the read_retry method which will retry up
# to 15 times to get a sensor reading (waiting 2 seconds between each retry).
humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)

# Un-comment the line below to convert the temperature to Fahrenheit.
# temperature = temperature * 9/5.0 + 32

# Note that sometimes you won't get a reading and
# the results will be null (because Linux can't
# guarantee the timing of calls to read the sensor).
# If this happens try again!

if humidity is not None and temperature is not None:
    with sqlite3.connect(sqlite_file) as conn:
        c = conn.cursor()
        c.execute(sql_create)
        c.execute(sql_insert, (round(temperature,2),round(humidity,2)))
    mqttc.connect("BROKER_IP", 1883, 60)
    mqttc.publish("/HIoH/measure/livingroom/temperature",'{0:.2f}'.format(temperature))
    mqttc.publish("/HIoH/measure/livingroom/humidity",'{0:.2f}'.format(humidity))
else:
    print('Failed to get reading. Try again!')
    sys.exit(1)
            
