#!/bin/bash
# developer: "徐光亮"<982641792@qq.com>
# 2017-6-10
tag="/usr/share/linuxer/linuxer.txt"
cat <<-EOF
   ---------------------------------------------------------------------
   This is linuxer, the Linux Experiment System. 

   Now let's study how to use linux.
  --------------------------------------------------------------------- 
EOF
if [ -e $tag ]; then
  /usr/share/linuxer/bin/start-terminal.bash
else
  echo "Please install experiment system first..."
  exit 0
fi
