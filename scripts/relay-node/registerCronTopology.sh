#!/bin/bash

# Registers a CRON job on the system to run the topologyUpdater.sh script
# NOTE: Only to be run once

cat > $NODE_HOME/crontab-fragment.txt << EOF
33 * * * * ${NODE_HOME}/topologyUpdater.sh
EOF
EDITOR=nano crontab -l | cat - ${NODE_HOME}/crontab-fragment.txt > ${NODE_HOME}/crontab.txt && crontab ${NODE_HOME}/crontab.txt
rm ${NODE_HOME}/crontab-fragment.txt