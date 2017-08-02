# TTN PKT FWD - Resin.io Edition!

This set of files will provision a [TTN](https://www.thethings.network/)
Gateway based on a Raspberry Pi and the IMST ic880a gateway board.

Connect the hardware as documented
[here](https://github.com/ttn-zh/ic880a-gateway/wiki) (We *really* recommend
using one of the backplane boards such as [this
one](https://www.tindie.com/products/gnz/imst-ic880a-lorawan-backplane/)) and
then set the following environment variables for each device in your
[Resin.io](https://resin.io) application.

| ENV Name | Value |
|----------|-------|
| GW_ID    | The gateway id from your TTN Console that you chose during registration|
| GW_KEY   | The long Base64 Encoded key that authorises your gateway to TTN |
| GW_RESET_PIN | The reset pin as documented on the data sheet. If you're using the simple backplane board, this should be set to `22` |

Once you've configured the above, add a remote to your clone of this repo as
documented in the Resin Dashboard, and `git push resin master`.

All Gateways that are registered to your application will download the
software, restart and register themselves with the TTN console.
