#!/bin/bash
for ((i=2;i<255;++i))
do
sudo /sbin/iptables -t nat -D PREROUTING 2
done

