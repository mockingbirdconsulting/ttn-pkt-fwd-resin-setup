=Features that still need to be added or are nice to haves=
* Use GWID and GWKEY to fetch the gateway's configuration from the TTN account server. The result should contain a link to the correct global_conf.json for the gateway's region. Also the antenna gain, router address, location. Use these to write an appropriate local_conf.json.

* Add ability to enable/disable TTN by environment variable. Default enabled.

* Ability to add up to 3 additional servers using environment variables. 
** Server type (deffault semtech)
** Server hostname/ip (default log.gatewaystats.org)
** server port (default 1700)
** downlink enabled (default off)
