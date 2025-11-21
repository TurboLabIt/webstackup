#!/usr/bin/env bash
### VARNISH CACHE MONITOR BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/varnish/monitor-cache.sh | sudo bash
#

sudo watch --color -t -n 2 'bash -c "
if [ -f \"/usr/local/turbolab.it/bash-fx/bash-fx.sh\" ]; then
  source \"/usr/local/turbolab.it/bash-fx/bash-fx.sh\"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi

fxHeader \"👁️‍🗨️ VARNISH CACHE MONITOR\"

varnishstat -1 -f SMA.s0.g_bytes -f SMA.s0.g_space | awk \"
BEGIN {
    print \\\"\\\"
    used = 0
    available = 0
}
/SMA.s0.g_bytes/ {
    used = \\\$2 / 1024 / 1024
}
/SMA.s0.g_space/ {
    available = \\\$2 / 1024 / 1024
}
END {
    total = used + available
    printf \\\"Varnish cache size:      %.2f MB\\\n\\\", total
    printf \\\"Varnish cache used:      %.2f MB\\\n\\\", used
    printf \\\"Varnish cache available: %.2f MB\\\n\\\", available
    if (total > 0) {
        percent = (used / total) * 100
        printf \\\"\\\n\\\\033[46;30mCache usage:             %.2f%%\\\\033[0m\\\n\\\", percent
    }
}\"
"'
