#Environment Variables
##Required global variables
* GW_ID required
* GW_KEY required
* GW_CONTACT_EMAIL required - default an empty string
  The gateway owner's contact information.

##Optional global variables
* GW_RESET_PIN - default 22
  The physical pin number on the Raspberry Pi to which the concentrator's reset is connected. If you followed the [TTN-ZH instruction](https://github.com/ttn-zh/ic880a-gateway/wiki), or used [Gonzalo Casas' backplane board](https://www.tindie.com/stores/gnz/), this is most likely pin number 22. As pin 22 is the default value, you do not need to define it in this case.
* GW_GPS optional - default False
  * If True, use the hardware GPS. 
  * If False, 
    use either fake gps if a location was configured in the TTN console, 
    otherwise try using fake gps with the reference location as set via environment variables, 
    otherwise don't send coordinates. 
* GW_GPS_PORT optional - default /dev/ttyAMA0
  The UART to which the hardware GPS is connected to.
* GW_REF_LATITUDE optional - default 0
  The latitude to use for fake gps if the coordinates are not set in the TTN console.
* GW_REF_LONGITUDE optional - default 0
  The longitude to use for fake gps if the coordinates are not set in the TTN console.
* GW_REF_ALTITUDE optional - default 0
  The altitude to use for fake gps if the coordinates are not set in the TTN console.

##Server variables
All server variables are optional, but when a server is enabled, it is recommended to set all variables to configure it completely.
* SERVER_TTN optional - default True
  Should the gateway connect to the TTN backend
  
* SERVER_1_ENABLED optional - default false
* SERVER_1_TYPE - default "semtech"
* SERVER_1_ADDRESS
* SERVER_1_PORTUP - only when using type semtech
* SERVER_1_PORTDOWN - only when using type semtech
* SERVER_1_GWID
* SERVER_1_GWKEY
* SERVER_1_DOWNLINK - default false

* SERVER_2_ENABLED optional - default false
* SERVER_2_TYPE - default "semtech"
* SERVER_2_ADDRESS
* SERVER_2_PORTUP - only when using type semtech
* SERVER_2_PORTDOWN - only when using type semtech
* SERVER_2_GWID
* SERVER_2_GWKEY
* SERVER_2_DOWNLINK - default false

* SERVER_3_ENABLED optional - default false
* SERVER_3_TYPE - default "semtech"
* SERVER_3_ADDRESS
* SERVER_3_PORTUP - only when using type semtech
* SERVER_3_PORTDOWN - only when using type semtech
* SERVER_3_GWID
* SERVER_3_GWKEY
* SERVER_3_DOWNLINK - default false

#Logal debugging
```
docker run --device /dev/ttyAMA0:/dev/ttyAMA0 --device /dev/mem:/dev/mem --privileged -e GW_TYPE="imst-ic880a-spi" -e GW_DESCRIPTION="test gateway" -e GW_CONTACT_EMAIL="" -e GW_ID="" -e GW_KEY="" newforwarder


```
Make a copy of `Dockerfile.template` to `Dockerfile`.
```
FROM resin/raspberrypi-buildpack-deps
...
CMD ["bash"]
```
