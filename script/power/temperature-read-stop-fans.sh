#!/usr/bin/env bash
## clear && sudo bash /usr/local/turbolab.it/webstackup/script/power/temperature-read-stop-fans.sh

echo ""

## bash-fx
if [ -z $(command -v curl) ]; then sudo apt update && sudo apt install curl -y; fi
if [ ! -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/master/setup.sh?$(date +%s) | sudo bash; fi
source /usr/local/turbolab.it/bash-fx/bash-fx.sh
## bash-fx is ready


fxHeader "🔇 Read the temperature, stop the fans!"
rootCheck


fxTitle "thermal_zone..."
## https://forum.chuwi.com/t/larkbox-fan-does-not-work-rigth-on-linux/14697/9
cat /sys/class/thermal/thermal_zone?/temp


fxTitle "sensors setup..."
## https://forum.proxmox.com/threads/temperature.67755/#post-304046
if [ -z $(command -v sensors) ]; then
  apt update && apt install lm-sensors -y
fi


fxTitle "Cron check..."
## https://github.com/TurboLabIt/webstackup/blob/master/config/cron/temperature-read-stop-fans
READ_TEMPS_CRON_FILE=/etc/cron.d/webstackup_temperature_read_stop_fans
if [ ! -f "$READ_TEMPS_CRON_FILE" ]; then

  cp /usr/local/turbolab.it/webstackup/config/cron/temperature-read-stop-fans "$READ_TEMPS_CRON_FILE"
  sensors-detect --auto
fi


fxTitle "sensors..."
sensors


fxEndFooter
