#!/usr/bin/env bash
echo ""

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ ! -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/master/setup.sh?$(date +%s) | sudo bash; fi
source /usr/local/turbolab.it/bash-fx/bash-fx.sh
## bash-fx is ready


fxHeader "🔇 Read the temperature, stop the fans!"
rootCheck


fxTitle "Cron check..."
## https://github.com/TurboLabIt/webstackup/blob/master/config/cron/temp-read-stop-fans
READ_TEMPS_CRON_FILE=/etc/cron.d/webstackup_temp_read
if [ ! -f "$READ_TEMPS_CRON_FILE" ]; then
  cp /usr/local/turbolab.it/webstackup/temp-read-stop-fans "$READ_TEMPS_CRON_FILE"
fi

fxTitle "thermal_zone..."
## https://forum.chuwi.com/t/larkbox-fan-does-not-work-rigth-on-linux/14697/9
cat /sys/class/thermal/thermal_zone?/temp


fxTitle "sensors..."
## https://forum.proxmox.com/threads/temperature.67755/#post-304046
if [ -z $(command -v sensors) ]; then apt update && apt install xsensors -y; fi
sensors


fxEndFooter
