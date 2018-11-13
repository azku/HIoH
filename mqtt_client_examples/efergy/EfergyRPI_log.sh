#! /bin/bash
#: Title       : Capture and decode Efergy electrisity meter data
#: Date        : 2018-11-07
#: Description : Captures Efergy electrisity meter output using rtl_fm and then decodes
#                The data with fergyRPI_log script

rtl_fm -f 433.52e6 -s 200e3 -r 96e3 -g 29.7 2> /dev/null | ./EfergyRPI_log
