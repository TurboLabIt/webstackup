#!/usr/bin/env bash
### AUTOMATIC SERVER BENCHMARK BY WEBSTACK.UP
# sudo apt install curl -y && curl -s https://raw.githubusercontent.com/TurboLabIt/webstackup/master/script/performance/benchmark.sh | sudo bash
#

## bash-fx
if [ -f "/usr/local/turbolab.it/bash-fx/bash-fx.sh" ]; then
  source "/usr/local/turbolab.it/bash-fx/bash-fx.sh"
else
  source <(curl -s https://raw.githubusercontent.com/TurboLabIt/bash-fx/main/bash-fx.sh)
fi
## bash-fx is ready

fxHeader "⏲️ Benchmark"
rootCheck

fxTitle "💿 Installing...."
apt update
apt install sysbench sysstat fio -y

fxTitle "CPU"
sysbench cpu --threads=1 run
fxMessage "Cfr i7-9750H            : 1.415 (events per second) | 14.162 (total number of events)"
fxMessage "Cfr Celeron J4115       : 1.439 (events per second) | 14.398 (total number of events)"
fxMessage "Cfr i7-7700 (datacenter): 1.172 (events per second) | 11.724 (total number of events)"

fxTitle "Disk (iostat)"
iostat -d | grep -vi loop

fxTitle "Disk (fio)"
fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fiotest --filename=testfio --bs=4k --iodepth=64 --size=2G --readwrite=randrw --rwmixread=75
rm -f "${HOME}testfio" "testfio"

fxEndFooter
