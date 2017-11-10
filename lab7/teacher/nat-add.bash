#!/bin/bash
for ((i=2;i<255;++i))
do
PORT=`printf "%03d" $i`
#echo "PORT=$PORT"
IP=172.17.0.$i
#echo "IP=$IP"
sudo /sbin/iptables -t nat -A PREROUTING  -d 10.11.8.17 -p tcp --dport=50$PORT -j DNAT --to-destination $IP:8888
done
