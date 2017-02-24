#! /bin/bash

mkdir -p /opt/ttn-gateway/dev
cd /opt/ttn-gateway/dev
git clone git://git.drogon.net/wiringPi
cd wiringPi
cd ..
git clone https://github.com/kersing/lora_gateway.git
git clone https://github.com/kersing/paho.mqtt.embedded-c.git
git clone https://github.com/kersing/ttn-gateway-connector.git
git clone https://github.com/kersing/protobuf-c.git
git clone https://github.com/kersing/packet_forwarder.git
git clone https://github.com/google/protobuf.git

apt update
apt install protobuf-compiler
apt install libprotobuf-dev
apt install libprotoc-dev
apt install automake
apt install libtool
apt install autoconf

cd lora_gateway/libloragw
sed -i -e 's/PLATFORM= .*$/PLATFORM= imst_rpi/g' library.cfg
sed -i -e 's/CFG_SPI= .*$/CFG_SPI= native/g' library.cfg
make

cd ../../protobuf-c
./autogen.sh
./configure
make protobuf-c/libprotobuf-c.la
mkdir bin
./libtool install /usr/bin/install -c protobuf-c/libprotobuf-c.la `pwd`/bin

cd ../paho.mqtt.embedded-c/
make
make install

cd ../ttn-gateway-connector
cp config.mk.in config.mk
make
cp bin/libttn-gateway-connector.so /usr/lib/

cd ../packet_forwarder/mp_pkt_fwd/
make

echo "Build & Installation Completed."
