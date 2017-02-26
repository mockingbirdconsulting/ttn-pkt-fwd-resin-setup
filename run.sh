#! /bin/bash

# Exit if we're debugging and haven't yet built the gateway

if [ ! -f  "mp_pkt_fwd" ]; then
    echo "ERROR: gateway executable not yet built"
    exit 1
fi

if [[ $HALT != "" ]]; then
    echo "*** HALT asserted - exiting ***"
    exit 1
fi

# Show info about the machine we're running on

echo "*** Resin Machine Info:"
echo "*** Type: '$RESIN_MACHINE_NAME'"
echo "*** Arch: '$RESIN_ARCH'"

##### Raspberry Pi 3 hacks necessary for LinkLabs boards
##
## Because of backward incompatibility between RPi2 and RPi3,
## a hack is necessary to get serial working so that we can
## access the GPS on the LinkLabs board.
##
## Option #1: Leave RPi serial on /dev/ttyS0 and bluetooth on /dev/ttyAMA0
##  This requires adding this Fleet Configuration variable, which
##  fixes RPi3 serial port speed issues:
##    RESIN_HOST_CONFIG_core_freq = 250
##
## Option #2: Disable bluetooth and put RPi serial back onto /dev/ttyAMA0
##  This requires adding this Fleet Configuration variable, which
##  swaps the bluetooth and serial uarts:
##    RESIN_HOST_CONFIG_dtoverlay=pi3-miniuart-bt
##
#####

if [[ $GW_TYPE == "" ]]; then
    echo "ERROR: GW_TYPE required"
    echo "See https://github.com/rayozzie/ttn-resin-gateway-rpi/blob/master/README.md"
    exit 1
fi

# We need to be online, wait if needed.

until $(curl --output /dev/null --silent --head --fail http://www.google.com); do
    echo "[TTN Gateway]: Waiting for internet connection..."
    sleep 30
done

# Ensure that we've got the required env vars

echo "*******************"
echo "*** Configuration:"
echo "*******************"

if [[ $GW_REGION == "" ]]; then
    echo "ERROR: GW_REGION required"
    exit 1
fi
GW_REGION=${GW_REGION^^}
echo GW_REGION: $GW_REGION

if [[ $GW_DESCRIPTION == "" ]]; then
    echo "ERROR: GW_DESCRIPTION required"
    echo "See https://github.com/rayozzie/ttn-resin-gateway-rpi/blob/master/README.md"
    exit 1
fi

if [[ $GW_CONTACT_EMAIL == "" ]]; then
    echo "ERROR: GW_CONTACT_EMAIL required"
    echo "See https://github.com/rayozzie/ttn-resin-gateway-rpi/blob/master/README.md"
    exit 1
fi

if [[ $GW_ID == "" ]]; then
    echo "ERROR: GW_ID required"
    echo "See https://www.thethingsnetwork.org/docs/gateways/registration.html#via-gateway-connector"
    exit 1
fi

if [[ $GW_KEY == "" ]]; then
    echo "ERROR: GW_KEY required"
    echo "See https://www.thethingsnetwork.org/docs/gateways/registration.html#via-gateway-connector"
    exit 1
fi

echo "******************"
echo ""

# Load the region-appropriate global config

if curl -sS --fail https://raw.githubusercontent.com/TheThingsNetwork/gateway-conf/master/$GW_REGION-global_conf.json --output ./global_conf.json
then
    echo Successfully loaded $GW_REGION-global_conf.json from TTN repo
else
    echo "******************"
    echo "ERROR: GW_REGION not found"
    echo "******************"
    exit 1
fi

# Fetch location info, which we'll use as a hint to the gateway software

if curl -sS --fail ipinfo.io --output ./ipinfo.json
then
    echo "Actual gateway location:"
    IPINFO=$(cat ./ipinfo.json)
    echo $IPINFO
else
    echo "Unable to determine gateway location"
    IPINFO="\"\""
fi

# Set up environmental defaults for local.conf

if [[ $GW_REF_LATITUDE == "" ]]; then GW_REF_LATITUDE="52.376364"; fi
if [[ $GW_REF_LONGITUDE == "" ]]; then GW_REF_LONGITUDE="4.884232"; fi
if [[ $GW_REF_ALTITUDE == "" ]]; then GW_REF_ALTITUDE="3"; fi

if [[ $GW_GPS == "" ]]; then GW_GPS="true"; fi

if [[ $GW_GPS_TTY_PATH == "" ]]
then
    # Default to AMA0 unless this is an RPi3 with core frequency set in fleet config vars
    GW_GPS_TTY_PATH="/dev/ttyAMA0"
    if [[ "$RESIN_MACHINE_NAME" == "raspberrypi3" && "$RESIN_HOST_CONFIG_core_freq" != "" ]]
    then
        GW_GPS_TTY_PATH="/dev/ttyS0"
    fi
fi

if [[ $GW_FAKE_GPS == "" ]]; then GW_FAKE_GPS="false"; fi

# Synthesize local.conf JSON from env vars

echo -e "{\n\
\t\"gateway_conf\": {\n\
\t\t\"ref_latitude\": $GW_REF_LATITUDE,\n\
\t\t\"ref_longitude\": $GW_REF_LONGITUDE,\n\
\t\t\"ref_altitude\": $GW_REF_ALTITUDE,\n\
\t\t\"contact_email\": \"$GW_CONTACT_EMAIL\",\n\
\t\t\"description\": \"$GW_DESCRIPTION\", \n\
\t\t\"gps\": $GW_GPS,\n\
\t\t\"gps_tty_path\": \"$GW_GPS_TTY_PATH\",\n\
\t\t\"fake_gps\": $GW_FAKE_GPS,\n\
\t\t\"gateway_ID\": \"0000000000000000\",\n\
\t\t\"servers\": [\n\
\t\t{\
\t\t\t\"serv_type\": \"ttn\",\n\
\t\t\t\"serv_address\": \"router.$GW_REGION.thethings.network\",\n\
\t\t\t\"serv_gw_id\": \"$GW_ID\",\n\
\t\t\t\"serv_gw_key\": \"$GW_KEY\",\n\
\t\t\t\"serv_enabled\": true\n\
\t\t}]\n\
\t}\n\
}" >./local_conf.json

echo "local_conf.json"
echo "==============="
cat local_conf.json
echo "==============="

echo "******************"
# get gateway ID from its MAC address
GWID_PREFIX="FFFE"
GWID=$(ip link show eth0 | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3$4$5$6}')

# replace last 8 digits of default gateway ID by actual GWID, in given JSON configuration file
sed -i 's/\(^\s*"gateway_ID":\s*"\).\{16\}"\s*\(,\?\).*$/\1'${GWID_PREFIX}${GWID}'"\2/' local_conf.json

echo "Gateway_ID set to "$GWID_PREFIX$GWID" "
echo "******************"
echo ""


# Fire up the forwarder.

while true
do

    # Reset the board to a known state prior to launching the forwarder

    if [[ $GW_TYPE == "imst-ic880a-spi" ]]; then
        echo "[TTN Gateway]: Toggling reset pin on IMST iC880A-SPI Board"
        gpio -1 mode 22 out
        gpio -1 write 22 0
        sleep 0.1
        gpio -1 write 22 1
        sleep 0.1
        gpio -1 write 22 0
        sleep 0.1
    elif [[ $GW_TYPE == "linklabs-dev" ]]; then
        echo "[TTN Gateway]: Toggling reset pin on LinkLabs Raspberry Pi Development Board"
        gpio -1 mode 29 out
        gpio -1 write 29 0
        sleep 0.1
        gpio -1 write 29 1
        sleep 0.1
        gpio -1 write 29 0
        sleep 0.1
    elif [[ $GW_TYPE == "risinghf" ]]; then
        ## found this info via gwrst.sh in the risinghf loriot concentrator install package
        ## that info toggled pin 2, which I must assume to be Wiring's GPIO02 and thus
        ## pin BCM27/RPI13 on Raspberry Pi. It couldn't be RPi pin 2 because that's 5VDC.
        echo "[TTN Gateway]: Toggling reset pin on Rising HF Board"
        gpio -1 mode 26 out
        gpio -1 write 26 0
        sleep 0.1
        gpio -1 write 26 1
        sleep 0.1
        gpio -1 write 26 0
        sleep 0.1
    elif [[ $GW_TYPE == "custom" ]]; then
        echo "[TTN Gateway]: Toggling custom reset pin $CUSTOM_RESET_PIN"
        gpio -1 mode $CUSTOM_RESET_PIN out
        gpio -1 write $CUSTOM_RESET_PIN 0
        sleep 0.1
        gpio -1 write $CUSTOM_RESET_PIN 1
        sleep 0.1
        gpio -1 write $CUSTOM_RESET_PIN 0
        sleep 0.1
    else
        echo "ERROR: unrecognized GW_TYPE=$GW_TYPE"
        echo "See https://github.com/rayozzie/ttn-resin-gateway-rpi/blob/master/README.md"
        exit 1
    fi

    echo "[TTN Gateway]: Starting packet forwarder..."
    ./mp_pkt_fwd
    echo "****************** $CUSTOM_RESET_PIN"
    echo "*** [TTN Gateway]: EXIT (retrying in 15s)"
    echo "******************"
    sleep 15

done
