# WARNING: Beta, unstable, testing software
This resin.io setup is based on the [Multi-protocol Packet Forwarder by Jac Kersing](https://github.com/kersing/packet_forwarder/tree/master/mp_pkt_fwd). His packet forwarder, as well as this resin.io setup, are changing constantly. You therefore need to `git pull origin master` and `git push -f resin master` at least once a week to make sure your gateway is running the latest software.

If you want a stable gateway setup, stick to the [old poly-packet-forwarder resin.io setup](https://github.com/rayozzie/ttn-resin-gateway-rpi) for now. You will be able to update from the old one to this repo quite seamlessly in the future.

# Resin.io TTN Gateway Connector for Raspberry Pi

Resin Dockerfile & scripts for [The Things Network](http://thethingsnetwork.org/) gateways based on the Raspberry Pi. This updated version uses the gateway connector protocol, not the old packet forwarder. See the [TTN documentation on Gateway Registration](https://www.thethingsnetwork.org/docs/gateways/registration.html).

Currently any Raspberry Pi with one of the following gateway boards, communicating over SPI, are supported, but not limited to these:
* [IMST iC880A-SPI](http://webshop.imst.de/ic880a-spi-lorawan-concentrator-868mhz.html). Preferable configured as described [by TTN-ZH](https://github.com/ttn-zh/ic880a-gateway/wiki). You **do not** need to follow the **Setting up the software** step, as the setup scripts in this repository does it for you.
* [LinkLabs Raspberry Pi "Hat"](http://link-labs.myshopify.com/products/lorawan-raspberry-pi-board)
* [RisingHF IoT Dicovery](http://www.risinghf.com/product/risinghf-iot-dicovery/?lang=en)

## Prerequisites

1. Build your hardware.
2. Create a new gateway that uses `gateway connector` on the [TTN Console](https://console.thethingsnetwork.org/gateways). Also set the location and altitude of your gateway. We will come back to this console later to obtain the gateway ID and access key.
3. Create and sign into an account at http://resin.io, which is the central "device dashboard".

## Create a resin.io application

1. On resin.io, create an "Application" for managing your TTN gateway devices. I'd suggest that you give it the name "ttngw", select the appropriate device type (i.e. Raspberry Pi 2 or Raspberry Pi 3),  and click "Create New Application".  You only need to do this once, after which you'll be able to manage one or many gateways of that type.
2. You'll then be brought to the Device Management dashboard for that Application.  Follow the instructions to "DOWNLOAD RESINOS" and create a boot SD-card for your Raspberry Pi. (Pro Tip:  Use a fast microSD card and a USB 3 adapter if you can, because it can take a while to copy all that data. Either that, or be prepared to be very patient.)
3. When the (long) process of writing the image to the SD card completes, insert it into your Raspberry Pi, connect it to the network with Ethernet, and power it up.
4. After several minutes, on the resin.io Devices dashboard you'll now see your device - first in a "Configuring" state, then "Idle".  Click it to open the Devices control panel.
5. If you like, enter any new Device Name that you'd like, such as "my-gateway-amsterdam".

## Configure the gateway device

Click the "Environment Variables" section at the left side of the screen. This will allow you to configure this and only this device. These variables will be used to pull information about this gateway from TTN, and will be used to create a "global_conf.json" and "local_conf.json" file for this gateway.

For a more complete list of possible environment variables, see [CONFIGURATION](CONFIGURATION.md).

### Device environment variables - no GPS

For example, for an IMST iC880A with no GPS, the MINIMUM environment variables that you should configure at this screen should look something like this:

Name      	  	   | Value  
------------------|--------------------------  
GW_TYPE           | imst-ic880a-spi
GW_CONTACT_EMAIL  | yourname@yourdomain.com
GW_ID             | The gateway ID from the TTN console
GW_KEY            | The gateway KEY from the TTN console
GW_RESET_PIN      | 22 (optional)

GW_RESET_PIN can be left out if you are using Gonzalo Casas' backplane board, or any other setup using pin 22 as reset pin. This is because pin 22 is the default reset pin used by this resin.io setup.


### Device environment variables - with GPS

For example a LinkLabs gateway, which has a built-in GPS, you need:

Name      	  	   | Value  
------------------|--------------------------  
GW_CONTACT_EMAIL  | yourname@yourdomain.com
GW_ID             | The gateway ID from the TTN console
GW_KEY            | The gateway KEY from the TTN console
GW_GPS            | true
GW_RESET_PIN      | 29


## Reset pin values

Depending on the way you connect the concentrator board to the Raspberry Pi, the reset pin of the concentrator might be on a different GPIO pin of the Raspberry Pi. Here follows a table of the most common backplane boards used, and the reset pin number you should use in the `GW_RESET_PIN` environment variable.

Note that the reset pin you should define is the physical pin number on the Raspberry Pi. To translate between different numbering schemes you can use [pinout.xyz](https://pinout.xyz/).

Backplane         | Reset pin
------------------|-----------
Gonzalo Casas backplane<br \>https://github.com/gonzalocasas/ic880a-backplane<br \>https://www.tindie.com/stores/gnz/ | 22
ch2i<br \>https://github.com/ch2i/iC880A-Raspberry-PI | 11
Linklabs Rasberry Pi Hat | 29 (untested)
Rising HF Board<br />http://www.risinghf.com/product/risinghf-iot-dicovery/?lang=en | 26


If you get the message
`ERROR: [main] failed to start the concentrator`
after resin.io is finished downloading the application, or when restarting the gateway, it most likely means the `GW_RESET_PIN` you defined is incorrect.


## SPECIAL Note for using the LinkLabs gateway on a Raspberry Pi 3

There is a backward incomatibility between the Raspberry Pi 1 and 2 hardware, and Raspberry Pi 3.  For Raspberry Pi 3, it is necessary to make a small additional configuration change.

Click <- to go back to the Device List, and note that on the left there is an option called "Fleet Configuration".  Click it.

Add a New config variable as follows:

### Application config variables

Name      	            	   | Value  
------------------------------|--------------------------  
RESIN_HOST_CONFIG_core_freq   | 250

## TRANSFERRING TTN GATEWAY SOFTWARE TO RESIN SO THAT IT MAY BE DOWNLOADED ON YOUR DEVICES

1. On your computer, clone this git repo. For example in a terminal on Mac or Linux type:

   ```bash
   git clone https://github.com/jpmeijers/ttn-resin-gateway-rpi.git
   ```
2. Now, type the command that you'll see displayed in the edit control in the upper-right corner of the Resin devices dashboard for your device. This command "connects" your local directory to the resin GIT service, which uses GIT to "receive" the gateway software from TTN, and it looks something like this:

   ```bash
   git remote add resin youraccount@git.resin.io:youraccount/yourapplication.git
   ```
3. Type the following commands into terminal to "push" the TTN files up to resin.io:

   ```bash
   git add .
   git commit -m "first upload of ttn files to resin"
   git push -f resin master
   ```
5. What you'll now see happening in terminal is that this "git push" does an incredible amount of work:
  1. It will upload a Dockerfile, a "build script", and a "run script" to resin
  2. It will start to do a "docker build" using that Dockerfile, running it within a QEMU ARM virtual machine on the resin service.
  3. In processing this docker build, it will run a "build.sh" script that downloads and builds the packet forwarder executable from source code, for RPi+iC880A-SPI.
  4. When the build is completed, you'll see a unicorn &#x1f984; ASCII graphic displayed in your terminal.

6. Now, switch back to your device dashboard, you'll see that your Raspberry Pi is now "updating" by pulling the Docker container from the resin.io service.  Then, after "updating", you'll see the gateway's log file in the window at the lower right corner.  You'll see it initializing, and will also see log output each time a packet is forwarded to TTN.  You're done!

## PRO TIPS

- At some point if you would like to add a second gateway, third gateway, or a hundred gateways, all you need to do is to add a new device to your existing Application. You needn't upload any new software to Resin, because Resin already knows what software belongs on the gateway. So long as the environment variables are configured correctly for that new device, it'll be up and running immediately after you burn an SD card and boot it.

- Resin will automatically restart the gateway software any time you change the environment variables.  You'll see this in the log.  Also, note that Resin restarts the gateway properly after power failures.  If the packet forwarder fails because of an error, it will also automatically attempt to restart.

- If you'd like to update the software across all the gateways in your device fleet, simply do the following:

  Edit the Dockerfile to bump the TTN_GATEWAY_VERSION number
  git add .
  git commit -m "Updated gateway version"
  git push -f resin master"
  
- For devices without a GPS, the location that is configured on the TTN console is used. This location is only read at startup of the gateway. Therefore, after you set or changed the location, restart the application from the resin.io console.

# Credits

* [Gonzalo Casas](https://github.com/gonzalocasas) on the [iC880a-based gateway](https://github.com/ttn-zh/ic880a-gateway/tree/spi)
* [Ruud Vlaming](https://github.com/devlaam) on the [Lorank8 installer](https://github.com/Ideetron/Lorank)
* [Jac Kersing](https://github.com/kersing) on the [Multi-protocol packet forwarder](https://github.com/kersing/packet_forwarder/tree/master/mp_pkt_fwd)
* [Ray Ozzie](https://github.com/rayozzie/ttn-resin-gateway-rpi) on the original ResinIO setup
* [The Team](https://resin.io/team/) at resin.io
