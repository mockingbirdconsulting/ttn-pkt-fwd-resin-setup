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
