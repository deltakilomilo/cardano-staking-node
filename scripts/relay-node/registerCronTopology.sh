#!/bin/bash

# Registers a CRON job on the system to run the topologyUpdater.sh script
# NOTE: Only to be run once

cat > /crontab-fragment.txt << EOF
33 * * * * /usr/bin/docker exec -it cardano-relay-node /cardano-node-home/topologyUpdater.sh
EOF
EDITOR=nano crontab -l | cat - /crontab-fragment.txt > /crontab.txt && crontab /crontab.txt
rm /crontab-fragment.txt