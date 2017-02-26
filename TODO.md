#TODO
##Features that still need to be added or are nice to have.

* Use GWID and GWKEY to fetch the gateway's configuration from the TTN account server. The result should contain a link to the correct global_conf.json for the gateway's region. Also the antenna gain, router address, location. Use these to write an appropriate local_conf.json.
  GET https://account.thethingsnetwork.org/gateways/<gw-id>
  Authorization: Key ttn-account-v2.######

* Add ability to enable/disable TTN by environment variable. Default enabled.

* Ability to add up to 3 additional servers using environment variables. 
  * Server type (deffault semtech)
  * Server hostname/ip (default log.gatewaystats.org)
  * server port (default 1700)
  * downlink enabled (default off)

##JSON response from TTN account server
```javascript
{
  "id": "jpm-test",
  "frequency_plan": "EU_863_870",
  "frequency_plan_url": "https://account.thethingsnetwork.org/api/v2/frequency-plans/EU_863_870",
  "public_rights": [],
  "location_public": false,
  "status_public": false,
  "owner_public": false,
  "attributes": {
    "description": "jp's test gateway",
    "placement": "indoor"
  },
  "router": "router.dev.thethings.network:1883",
  "location": {
    "lng": 6.602717846679752,
    "lat": 52.33979712058138
  },
  "altitude": 20,
  "owner": {
    "id": "######",
    "username": "jpmeijers"
  },
  "key": "ttn-account-v2.######",
  "auto_update": true,
  "activated": false,
  "firmware_url": "http://ttnreleases.blob.core.windows.net/the-things-gateway/v1",
  "token": {
    "expires_in": 8035200,
    "access_token": "######"
  }
}
```

##Environment Variables
###Required global variables
* GW_TYPE required
* GW_ID required
* GW_KEY required
* GW_CONTACT_EMAIL required - default an empty string
  The gateway owner's contact information.

###Optional global variables
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

###Server variables
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
