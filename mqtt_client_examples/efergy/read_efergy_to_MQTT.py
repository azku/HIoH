#!/usr/bin/python
# Author: Asier Azkuenaga

import subprocess
import paho.mqtt.client as mqtt
import sqlite3

sqlite_file = 'PATH_TO_DB'
table_name = 'EFERGY'
sql_create = "CREATE TABLE IF NOT EXISTS %s (id INTEGER PRIMARY KEY, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, power REAL)" % (table_name)
sql_insert = "insert into %s(power) values(?) " % (table_name)

mqttc = mqtt.Client(None)
mqttc.username_pw_set("user", "password")

executable_path = 'PathToExecutableBash/EfergyRPI_log.sh'
process = subprocess.Popen(['sh', executable_path], stdout=subprocess.PIPE)
mqttc.connect("MQTT_broker_IP", 1883, 60)
while True:
    output = process.stdout.readline()
    if output == '' and process.poll() is not None:
        break
    if output:
        output_arr = output.decode('UTF-8').replace('\n','').split(',')
        if len(output_arr) == 3:
            power_value = float(output_arr[-1])
            if power_value < 10000:
                with sqlite3.connect(sqlite_file) as conn:
                    c = conn.cursor()
                    c.execute(sql_create)
                    c.execute(sql_insert, (round(power_value,2),))
                    mqttc.publish("/HIoH/measure/all/power",'{0:.2f}'.format(power_value))
    rc = process.poll()
