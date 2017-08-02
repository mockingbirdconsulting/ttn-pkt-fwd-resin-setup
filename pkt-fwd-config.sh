#!/bin/bash
cat > /etc/ttn-pkt-fwd.yml  <<-EOF
id: ${GW_ID}
key: ${GW_KEY}
reset-pin: ${GW_RESET_PIN}
EOF
